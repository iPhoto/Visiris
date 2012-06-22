//
//  VisirisCore.m
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSRenderCore.h"
#import "VSFrameCoreHandover.h"
#import "VSQuartzComposerHandover.h"
#import "VSFrameBufferObject.h"
#import "VSTexture.h"
#import "VSShader.h"
#import "VSTextureManager.h"
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
    
@implementation VSRenderCore
@synthesize delegate = _delegate;
@synthesize pixelFormat = _pixelFormat;
@synthesize openGLContext = _openGLContext;
@synthesize frameBufferObjectOne = _frameBufferObjectOne;
@synthesize frameBufferObjectTwo = _frameBufferObjectTwo;
@synthesize frameBufferObjectCurrent = _frameBufferObjectCurrent;
@synthesize frameBufferObjectOld = _frameBufferObjectOld;
//@synthesize textureBelow = _textureBelow;
//@synthesize textureUp = _textureUp;
@synthesize shader = _shader;
@synthesize textureManager = _textureManager;
@synthesize outPutTexture = _outPutTexture;

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
        
        // NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
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
        //self.outPutTexture = [[VSTexture alloc] initEmptyTextureWithSize:(NSMakeSize(640, 480)];
        
    }
    return self;
}


-(void)renderFrameOfCoreHandovers:(NSArray *) theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double)theTimestamp{
    NSMutableArray *mutableCoreHandovers = [NSMutableArray arrayWithArray:theCoreHandovers];
    
    for(VSCoreHandover *coreHandover in theCoreHandovers){
        if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            VSFrameCoreHandover *convertedQuartzComposerHandover = [self createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) coreHandover];
            [mutableCoreHandovers replaceObjectAtIndex:[mutableCoreHandovers indexOfObject:coreHandover] withObject:convertedQuartzComposerHandover];
        }
    }
        
    
    /////
    NSIndexSet *indexSet = [theCoreHandovers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[VSFrameCoreHandover class]]) {
            if (((VSFrameCoreHandover *)obj).frame) {
                return YES;
            }
        }
        return NO;
    } ];
    
    NSArray *validCoreHandovers = [[NSArray alloc] initWithArray:[theCoreHandovers objectsAtIndexes:indexSet]];
    //////
    
    
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
    // Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
    
    NSMutableArray *textures = [self createTextures:mutableCoreHandovers];
    
    switch (validCoreHandovers.count) {
        case 0:
        {
            //TODO
            //NSLog(@"ERROR: you shouldn't be here - because there is no object to render");
            self.outPutTexture = 0;
            break;
        }
        case 1:
        {
            VSFrameCoreHandover *handOver = (VSFrameCoreHandover*)[validCoreHandovers objectAtIndex:0];
            VSTexture *handOverTexture = [self.textureManager getVSTextureForTexId:handOver.textureID];
            [handOverTexture replaceContent:handOver.frame timeLineObjectId:handOver.timeLineObjectID];
            self.outPutTexture = handOverTexture.texture;
            [[self openGLContext] flushBuffer];
            break;
        }
        case 2:
        {
            NSLog(@"unsupported");
            [self combineTheFirstTwoObjects:validCoreHandovers];
            self.outPutTexture = self.frameBufferObjectCurrent.texture;
            [[self openGLContext] flushBuffer];
            break;
        }
        default:
        {            
            NSLog(@"unsupported");
            [self combineTheFirstTwoObjects:validCoreHandovers];
            

            
            for (NSInteger i = 1; i < validCoreHandovers.count -1; i++) {
                [self swapFBO];

                VSFrameCoreHandover *handOver = (VSFrameCoreHandover*)[validCoreHandovers objectAtIndex:(i+1)];
                VSTexture *handOverTexture = [self.textureManager getVSTextureForTexId:handOver.textureID];
                
                //Replace Content of the VSTexture EXPENSIVE 
                //TODO: should only replace when the timeLineObjectId is not identical
                [handOverTexture replaceContent:handOver.frame timeLineObjectId:handOver.timeLineObjectID];
                
                [self combineTexture:self.frameBufferObjectOld.texture with:handOverTexture.texture];
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

- (void)combineTheFirstTwoObjects:(NSArray *) mutableCoreHandovers{
    VSTexture *temp = [self.textureManager getVSTextureForTexId:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:0]).textureID];
    VSTexture *temp2 = [self.textureManager getVSTextureForTexId:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:1]).textureID];
    
    [temp replaceContent:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:0]).frame timeLineObjectId:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:0]).timeLineObjectID];
    [temp2 replaceContent:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:1]).frame timeLineObjectId: ((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:1]).timeLineObjectID];
    
    [self combineTexture:temp.texture with:temp2.texture];
}


- (void)combineTexture:(GLuint)bottomtexture with:(GLuint)upperTexture
{	
    [self.frameBufferObjectCurrent bind];
    
    glViewport(0, 0, self.frameBufferObjectCurrent.size.width,self.frameBufferObjectCurrent.size.height);
   
    //do i need this?
   // glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
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

    [[self openGLContext] flushBuffer];
    
    [self.frameBufferObjectCurrent unbind];
}

- (NSInteger)make_resources{
    g_resources.vertex_buffer = make_buffer(GL_ARRAY_BUFFER,g_vertex_buffer_data,sizeof(g_vertex_buffer_data));
    g_resources.element_buffer = make_buffer(GL_ELEMENT_ARRAY_BUFFER,g_element_buffer_data,sizeof(g_element_buffer_data));
    return 1;
}

- (GLuint)createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*) colorMode forTrack:(NSInteger)trackID{
    return [self.textureManager createTextureWithSize:textureSize trackId:trackID];
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

- (NSMutableArray *)createTextures:(NSArray *)handovers{
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    
    for(VSCoreHandover *coreHandover in handovers){
        if ([coreHandover isKindOfClass:[VSFrameCoreHandover class]]) {
            //NSLog(@"FrameCoreHandover");
            
            VSFrameCoreHandover *handOver = (VSFrameCoreHandover*)coreHandover;
            VSTexture *handOverTexture = [self.textureManager getVSTextureForTexId:handOver.textureID];
            [handOverTexture replaceContent:handOver.frame timeLineObjectId:handOver.timeLineObjectID];
            [textures addObject:handOverTexture];
        }
        else if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            NSLog(@"QuartzCoreHandover not implemented yet");
        }
    }
    
    
    
    return textures;
}

-(VSFrameCoreHandover *) createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) quartzComposerHandover{
    
    VSFrameCoreHandover *coreHandover = nil;
    
    if (quartzComposerHandover) {
        NSLog(@"Not Implemented Yet");
    }
    
    return coreHandover;
}

@end
