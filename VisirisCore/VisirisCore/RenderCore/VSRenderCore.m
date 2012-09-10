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
#import "VSLayerShader.h"
#import "VSTransformTextureManager.h"

@interface VSRenderCore()

/** Defines the coordinate for the plane */
@property (assign) GLuint                           vertex_buffer;

/** Defines the ordering of the vertices of the vertex buffer */
@property (assign) GLuint                           element_buffer;

/** The main OpenGLConext */
@property (strong) NSOpenGLContext                  *openGLContext;

/** The Pixelformat is needed for the GLContext */
@property (strong) NSOpenGLPixelFormat              *pixelFormat;

/** Is needed for PingPong rendering  */
@property (strong) VSFrameBufferObject              *frameBufferObjectOne;

/** Is needed for PingPong rendering  */
@property (strong) VSFrameBufferObject              *frameBufferObjectTwo;

/** References the current FBO */
@property (weak) VSFrameBufferObject                *frameBufferObjectCurrent;

/** References the old FBO */
@property (weak) VSFrameBufferObject                *frameBufferObjectOld;

/** The LayerShader is needed when 2 or more objects have to be mixed to one texture */
@property (strong) VSLayerShader                    *layerShader;

/** Texture Manager stores the VSTextures for Images and Videos */
@property (strong) VSTextureManager                 *textureManager;

/** Stores the QuartzRenderer */
@property (strong) VSQCManager                      *qcpManager;

/** Transform every Texture */
@property (strong) VSTransformTextureManager        *transformTextureManager;

@end


@implementation VSRenderCore
@synthesize vertex_buffer               = _vertex_buffer;
@synthesize element_buffer              = _element_buffer;
@synthesize delegate                    = _delegate;
@synthesize pixelFormat                 = _pixelFormat;
@synthesize openGLContext               = _openGLContext;
@synthesize frameBufferObjectOne        = _frameBufferObjectOne;
@synthesize frameBufferObjectTwo        = _frameBufferObjectTwo;
@synthesize frameBufferObjectCurrent    = _frameBufferObjectCurrent;
@synthesize frameBufferObjectOld        = _frameBufferObjectOld;
@synthesize layerShader                 = _layerShader;
@synthesize textureManager              = _textureManager;
@synthesize qcpManager                  = _qcpManager;
@synthesize transformTextureManager     = _transformTextureManager;

#pragma mark- Init

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
        
        self.layerShader = [[VSLayerShader alloc] init];

        self.textureManager = [[VSTextureManager alloc] init];        
        self.qcpManager = [[VSQCManager alloc] init];       
        
        self.transformTextureManager = [[VSTransformTextureManager alloc] initWithContext:self.openGLContext];
    }
    return self;
}

#pragma mark- Methods

-(void)renderFrameOfCoreHandovers:(NSArray *)theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double)theTimestamp{
    
    NSMutableArray *mutableCoreHandovers = [NSMutableArray arrayWithArray:theCoreHandovers];
    
	[[self openGLContext] makeCurrentContext];

    //Create a array with only glTextures in it
    NSMutableArray *textures = [self createTextures:mutableCoreHandovers atTime:theTimestamp forOutputSize:theFrameSize];
    
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
    GLuint outPutTexture;
    
    switch (textures.count) {
        case 0:
        {
            NSLog(@"ERROR: you shouldn't be here - because there is no object to render");
            outPutTexture = 0;
            break;
        }
        case 1:
        {
            NSNumber *texture = (NSNumber *)[textures objectAtIndex:0];
            outPutTexture = texture.intValue;
            [[self openGLContext] flushBuffer];
            break;
        }
        case 2:
        {
            [self combineTheFirstTwoObjects:textures];
            outPutTexture = self.frameBufferObjectCurrent.texture;
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
             
            outPutTexture = self.frameBufferObjectCurrent.texture;
            break;
        }
    }
    
    //NSLog(@"outputtexture: %d",outPutTexture);
    
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(renderCore:didFinishRenderingTexture:forTimestamp:)]) {
            [self.delegate renderCore:self didFinishRenderingTexture:outPutTexture forTimestamp:theTimestamp];
        }
    }
}

- (void)createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*)colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path withObjectItemID:(NSInteger)objectItemID{
    
    
    switch (type) {
        case VSFileKindImage:
            [self.textureManager createTextureWithSize:textureSize trackId:trackID withObjectItemID:objectItemID];
            [self.transformTextureManager createFBOWithSize:size trackId:trackID];
            break;
        case VSFileKindVideo:
            //TODO the same as above - plz optimise this shit
            [self.textureManager createTextureWithSize:textureSize trackId:trackID withObjectItemID:objectItemID];
            [self.transformTextureManager createFBOWithSize:size trackId:trackID];
            break;
        case VSFileKindQuartzComposerPatch:
            [self.qcpManager createQCRendererWithSize:size withTrackId:trackID withPath:path withContext:self.openGLContext withFormat:self.pixelFormat withObjectItemID:objectItemID];
            [self.transformTextureManager createFBOWithSize:size trackId:trackID];
            break;
        case VSFileKindAudio:
            NSLog(@"There is something fucked up, this path should have never been entered");
            break;
            
        default:
            break;
    }
}

- (void)deleteTextureFortimelineobjectID:(NSInteger)theID{
    [self.textureManager deleteTextureForTimelineobjectID:theID];
}

- (NSOpenGLContext *)openglContext{
    return self.openGLContext;
}

#pragma mark - Private Methods

/**
 * Reads the first two textures of an Array and calls the combineTexture Method.
 * @param textures NSArray with the stored textures
 */
- (void)combineTheFirstTwoObjects:(NSArray *) textures{
    NSNumber *texture0 = (NSNumber *)[textures objectAtIndex:0];
    NSNumber *texture1 = (NSNumber *)[textures objectAtIndex:1];
    
    [self combineTexture:texture0.intValue with:texture1.intValue];
}

/**
 * Combines two textures using the Layeringshader. The created texture gets offlinerendered using the current active FBO.
 * @param bottomtexture BaseTexture
 * @param upperTexture BlendTexture
 */
- (void)combineTexture:(GLuint)bottomtexture with:(GLuint)upperTexture{	
    [self.frameBufferObjectCurrent bind];
    
    glViewport(0, 0, self.frameBufferObjectCurrent.size.width,self.frameBufferObjectCurrent.size.height);
   
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(0.0f, 0.0f, 0.0f);
        
    glUseProgram(self.layerShader.program);
    glUniform1f(self.layerShader.uniformFadefactor, 0.5f);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, bottomtexture);
    glUniform1i(self.layerShader.uniformTexture1, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, upperTexture);
    glUniform1i(self.layerShader.uniformTexture2, 1);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertex_buffer);
    glVertexAttribPointer(self.layerShader.attributePosition,  /* attribute */
                          2,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*2,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(self.layerShader.attributePosition);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
    glDisableVertexAttribArray(self.layerShader.attributePosition);
    
    [self.frameBufferObjectCurrent unbind];
    [[self openGLContext] flushBuffer];
}

/**
 * This Method simply change the current FBO to old and vice versa. Is needed for Ping Pong Rendering.
 */
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

/**
 * Takes the Handoverarry and creates another Array with only updated OpenGLTextures. 
 * @param handovers Array containing the information
 * @param time Current Timestamp - is needed for Quartzcomposer.
 * @param outputSize NSSize of the current Resolution of the final OutputImage
 * @return NSMutableArraz with only GLuint Textures in it.
 */
- (NSMutableArray *)createTextures:(NSArray *)handovers atTime:(double)time forOutputSize:(NSSize)outputSize{
    
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    
    //cycles through handovers
    for(VSCoreHandover *coreHandover in handovers){
        
        //Case for Frames (Images and Videos)
        if ([coreHandover isKindOfClass:[VSFrameCoreHandover class]]){         
            
            VSFrameCoreHandover *handOver = (VSFrameCoreHandover *)coreHandover;
            
            VSTexture *handOverTexture = [self.textureManager getVSTextureForTimelineobjectID:handOver.timeLineObjectID];
            
            [handOverTexture replaceContent:handOver.frame timeLineObjectId:handOver.timeLineObjectID];
            [textures addObject:[NSNumber numberWithInt:[self.transformTextureManager transformTexture:handOverTexture.texture 
                                                                                               atTrack:handOverTexture.trackId 
                                                                                        withAttributes:coreHandover.attributes 
                                                                                       withTextureSize:handOverTexture.size
                                                                                         forOutputSize:outputSize
                                                                                             isQCPatch:NO]]];
            
        }
        //Case for Quartzstuff
        else if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            
            VSQuartzComposerHandover *handover = (VSQuartzComposerHandover *)coreHandover;
            VSQCRenderer *qcRenderer = [self.qcpManager getQCRendererForObjectId:handover.timeLineObjectID];
            
            id qcPublicInputValues = [handover.attributes objectForKey:VSParameterQuartzComposerPublicInputs];
            
            if([qcPublicInputValues isKindOfClass:[NSDictionary class]]){
                [qcRenderer setPublicInputsWithValues:qcPublicInputValues];
            }
                        
            [textures addObject:[NSNumber numberWithInt:[self.transformTextureManager transformTexture:[qcRenderer renderAtTme:handover.timestamp]
                                                                                               atTrack:qcRenderer.trackId 
                                                                                        withAttributes:coreHandover.attributes 
                                                                                       withTextureSize:qcRenderer.size 
                                                                                         forOutputSize:outputSize
                                                                                             isQCPatch:YES]]];
             
            
        }
        else (NSLog(@"WTF happend?!?"));
    }
    return textures;
}


/**
 * Basic Buffercreation for the plane
 * @return 1 if everything succeded
 */
- (NSInteger)make_resources{
    GLfloat g_vertex_buffer_data[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f
    };
    
    GLushort g_element_buffer_data[] = { 0, 1, 2, 3 };
    
    self.vertex_buffer = [self make_buffer:GL_ARRAY_BUFFER withData:g_vertex_buffer_data withSize:sizeof(g_vertex_buffer_data)];
    self.element_buffer = [self make_buffer:GL_ELEMENT_ARRAY_BUFFER withData:g_element_buffer_data withSize:sizeof(g_element_buffer_data)];
    
    return 1;
}

/**
 * Helper Method for creating a buffer
 * @param target Type of Buffer
 * @param buffer_data The Plain Buffer Data
 * @param buffer_size Size of the Buffer. Can be found out using sizeof()
 * @return ID of the Buffer in the current active Context
 */
- (GLuint) make_buffer:(GLenum)target withData:(const void *)buffer_data withSize:(GLsizei)buffer_size{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, buffer_size, buffer_data, GL_STATIC_DRAW);
    return buffer;
}

@end
