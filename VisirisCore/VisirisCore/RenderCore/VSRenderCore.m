//
//  VisirisCore.m
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSRenderCore.h"
#import "VSFrameCoreHandover.h"
#import "VSParameterTypes.h"
#import "VSQuartzComposerHandover.h"
#import "VSFrameBufferObject.h"
#import "VSTexture.h"
#import "VSShader.h"
#import "VSTextureManager.h"
#import "VSQCManager.h"
#import "VSQCRenderer.h"
#import <OpenGL/glu.h>

//FixeMe: Warum sind die static Methoden außerhalb der Klasse definiert?

static const GLfloat g_vertex_buffer_data[] = { 
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f
};

static const GLushort g_element_buffer_data[] = { 0, 1, 2, 3 };

static GLuint make_buffer(GLenum target,const void *buffer_data,GLsizei buffer_size) {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, buffer_size, buffer_data, GL_STATIC_DRAW);
    return buffer;
}

static struct {
    GLuint vertex_buffer, element_buffer;
} g_resources;


@interface VSRenderCore()

@property (strong) NSOpenGLContext                  *openGLContext;
@property (strong) NSOpenGLPixelFormat              *pixelFormat;        
@property (strong) VSFrameBufferObject              *frameBufferObjectOne;
@property (strong) VSFrameBufferObject              *frameBufferObjectTwo;
@property (strong) VSFrameBufferObject              *frameBufferObjectCurrent;
@property (strong) VSFrameBufferObject              *frameBufferObjectOld;
@property (strong) VSShader                         *shader;
@property (strong) VSTextureManager                 *textureManager;
@property (assign) GLuint                           outPutTexture;
@property (strong) VSQCManager                      *qcpManager;

@end

    
@implementation VSRenderCore
@synthesize delegate                    = _delegate;
@synthesize pixelFormat                 = _pixelFormat;
@synthesize openGLContext               = _openGLContext;
@synthesize frameBufferObjectOne        = _frameBufferObjectOne;
@synthesize frameBufferObjectTwo        = _frameBufferObjectTwo;
@synthesize frameBufferObjectCurrent    = _frameBufferObjectCurrent;
@synthesize frameBufferObjectOld        = _frameBufferObjectOld;
@synthesize shader                      = _shader;
@synthesize textureManager              = _textureManager;
@synthesize outPutTexture               = _outPutTexture;
@synthesize qcpManager                  = _qcpManager;

-(id)init{
    self = [super init];
    if (self) {
        
        NSOpenGLPixelFormatAttribute attribs[] =
        {
            kCGLPFAAccelerated,
            kCGLPFANoRecovery,
            kCGLPFADoubleBuffer,
            kCGLPFAColorSize, 24,
            kCGLPFADepthSize, 16,
            0
        };
        
        _pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
        
        if (!_pixelFormat)
            NSLog(@"No OpenGL pixel format");
        
        _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
        
        [ _openGLContext makeCurrentContext];
        
        GLint swapInt = 1;
		[ _openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
		
        
        if([self make_resources] == 0){
            NSLog(@"Error: Making Resources Failed!!!!!");
        }
        
        self.frameBufferObjectOne = [[VSFrameBufferObject alloc] init];
        self.frameBufferObjectTwo = [[VSFrameBufferObject alloc] init];
        self.frameBufferObjectCurrent = self.frameBufferObjectOne;
        self.frameBufferObjectOld = self.frameBufferObjectTwo;
        
        self.shader = [[VSShader alloc] init];
        self.textureManager = [[VSTextureManager alloc] init];        
        self.qcpManager = [[VSQCManager alloc] init];       
    }
    return self;
}


-(void)renderFrameOfCoreHandovers:(NSArray *) theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double)theTimestamp{
    NSMutableArray *mutableCoreHandovers = [NSMutableArray arrayWithArray:theCoreHandovers];
    
    
	[[self openGLContext] makeCurrentContext];

    //Create a array with only glTextures in it
    NSMutableArray *textures = [self createTextures:mutableCoreHandovers atTime:theTimestamp];
    
    CGLLockContext([[self openGLContext] CGLContextObj]);

    switch (textures.count) {
        case 0:
        {
            //TODO
            //NSLog(@"ERROR: you shouldn't be here - because there is no object to render");
            self.outPutTexture = 0;
            break;
        }
        case 1:
        {
            NSNumber *texture = (NSNumber *)[textures objectAtIndex:0];
            self.outPutTexture = texture.intValue;
            [[self openGLContext] flushBuffer];
            break;
        }
        case 2:
        {
            [self combineTheFirstTwoObjects:textures];
            self.outPutTexture = self.frameBufferObjectCurrent.texture;
            [[self openGLContext] flushBuffer];
            break;
        }
        default:
        {            
            [self combineTheFirstTwoObjects:textures];

            for (NSInteger i = 1; i < textures.count -1; i++) {
                [self swapFBO];
                NSNumber *texture = (NSNumber *)[textures objectAtIndex:(i+1)];
                [self combineTexture:self.frameBufferObjectOld.texture with:texture.intValue];
            }
             
            self.outPutTexture = self.frameBufferObjectCurrent.texture;
            break;
        }
    }
    
	CGLUnlockContext([[self openGLContext] CGLContextObj]);

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(renderCore:didFinishRenderingTexture:forTimestamp:)]) {
            [self.delegate renderCore:self didFinishRenderingTexture:self.outPutTexture forTimestamp:theTimestamp];
        }
    }
}

- (void)combineTheFirstTwoObjects:(NSArray *) textures{
    NSNumber *texture0 = (NSNumber *)[textures objectAtIndex:0];
    NSNumber *texture1 = (NSNumber *)[textures objectAtIndex:1];
    
    [self combineTexture:texture0.intValue with:texture1.intValue];
}


- (void)combineTexture:(GLuint)bottomtexture with:(GLuint)upperTexture{	
    [self.frameBufferObjectCurrent bind];
    
    glViewport(0, 0, self.frameBufferObjectCurrent.size.width,self.frameBufferObjectCurrent.size.height);
   
    glClear(GL_COLOR_BUFFER_BIT);
   // glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
    glUseProgram(self.shader.program);
    glUniform1f(self.shader.uniformFadefactor, 0.5f);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, bottomtexture);
    glUniform1i(self.shader.uniformTexture1, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, upperTexture);
    glUniform1i(self.shader.uniformTexture2, 1);
    
    glBindBuffer(GL_ARRAY_BUFFER, g_resources.vertex_buffer);
    glVertexAttribPointer(self.shader.attributePosition,  /* attribute */
                          2,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*2,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(self.shader.attributePosition);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_resources.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
    glDisableVertexAttribArray(self.shader.attributePosition);

    
    [self.frameBufferObjectCurrent unbind];
    [[self openGLContext] flushBuffer];

}

- (NSInteger)make_resources{
    g_resources.vertex_buffer = make_buffer(GL_ARRAY_BUFFER,g_vertex_buffer_data,sizeof(g_vertex_buffer_data));
    g_resources.element_buffer = make_buffer(GL_ELEMENT_ARRAY_BUFFER,g_element_buffer_data,sizeof(g_element_buffer_data));
    return 1;
}

- (GLuint)createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*)colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path{
    
    GLuint texture;
    
    switch (type) {
        case VSFileKindImage:
            texture = [self.textureManager createTextureWithSize:textureSize trackId:trackID];
            break;
        case VSFileKindVideo:
            texture = [self.textureManager createTextureWithSize:textureSize trackId:trackID];
            break;
        case VSFileKindQuartzComposerPatch:
            texture = [self.qcpManager createQCRendererWithSize:size withTrackId:trackID withPath:path withContext:self.openGLContext withFormat:self.pixelFormat];
            break;
        case VSFileKindAudio:
            NSLog(@"Audio not implemented yet");
            break;
            
        default:
            break;
    }
    
    return texture;
}

- (void)swapFBO{
    if (self.frameBufferObjectCurrent == self.frameBufferObjectOne) {
        self.frameBufferObjectCurrent = self.frameBufferObjectTwo;
        self.frameBufferObjectOld = self.frameBufferObjectOne;
    }
    else {
        self.frameBufferObjectCurrent = self.frameBufferObjectOne;
        self.frameBufferObjectOld = self.frameBufferObjectTwo;
    }
}

- (NSMutableArray *)createTextures:(NSArray *)handovers atTime:(double)time{
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    
    for(VSCoreHandover *coreHandover in handovers){
        
        if ([coreHandover isKindOfClass:[VSFrameCoreHandover class]]){         
            
            VSFrameCoreHandover *handOver = (VSFrameCoreHandover *)coreHandover;
            VSTexture *handOverTexture = [self.textureManager getVSTextureForTexId:handOver.textureID];
            [handOverTexture replaceContent:handOver.frame timeLineObjectId:handOver.timeLineObjectID];
            [textures addObject:[NSNumber numberWithInt:handOverTexture.texture]];
            
        }
        else if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            
            VSQuartzComposerHandover *handover = (VSQuartzComposerHandover *)coreHandover;
            VSQCRenderer *qcRenderer = [self.qcpManager getQCRendererForId:handover.textureID];
            
            id qcPublicInputValues = [handover.attributes objectForKey:VSParameterQuartzComposerPublicInputs];
            
            if([qcPublicInputValues isKindOfClass:[NSDictionary class]]){
                [qcRenderer setPublicInputsWithValues:qcPublicInputValues];
            }
                        
            [textures addObject:[NSNumber numberWithInt:[qcRenderer renderAtTme:time]]];
        }
    }
    return textures;
}

- (NSOpenGLContext *)openglContext{
    return self.openGLContext;
}

@end
