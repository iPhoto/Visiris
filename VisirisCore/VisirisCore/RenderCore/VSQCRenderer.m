//
//  VSQCRenderer.m
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQCRenderer.h"
#import <Quartz/Quartz.h>
#import "VSFrameBufferObject.h"
#import "VSPBufferRenderer.h"

@interface VSQCRenderer()
@property (strong) QCRenderer           *qcRenderer;
@property (strong) NSOpenGLContext      *context;
@property (strong) NSOpenGLPixelFormat  *pixelFormat;
@property (strong) VSFrameBufferObject  *fbo;
@property (strong) VSPBufferRenderer    *pBufferRenderer;

@end

@implementation VSQCRenderer
@synthesize qcRenderer          = _qcRenderer;
@synthesize context             = _context;
@synthesize pixelFormat         = _pixelFormat;
@synthesize fbo                 = _fbo;
@synthesize timeLineObjectId    = _timeLineObjectId;
@synthesize trackId             = _trackId;
@synthesize pBufferRenderer     = _pBufferRenderer;

- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format{
    if (self = [super init]) {
        
        
        
        self.context = context;
        self.pixelFormat = format;
        
  //      NSOpenGLPixelFormatAttribute	attributes[] = {NSOpenGLPFAAccelerated, NSOpenGLPFANoRecovery, NSOpenGLPFADoubleBuffer, NSOpenGLPFADepthSize, 24, 0};
    //    GLint							swapInterval = 1;
        
        //Create the OpenGL context used to render the animation and attach it to the rendering view
   //     self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    //    self.context = [[NSOpenGLContext alloc] initWithFormat:self.pixelFormat shareContext:context];
      //  [self.context setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];

        self.pBufferRenderer = [[VSPBufferRenderer alloc] initWithCompositionPath:path textureTarget:GL_TEXTURE_2D textureWidth:size.width textureHeight:size.height openGLContext:self.context];


/*
        NSOpenGLPixelFormatAttribute	attributes[] = {
            NSOpenGLPFAPixelBuffer,
            NSOpenGLPFANoRecovery,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADepthSize, 24,
            (NSOpenGLPixelFormatAttribute) 0
        };*/
        
        //self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];

        
        
      //  self.context = [[NSOpenGLContext alloc] initWithFormat:self.pixelFormat shareContext:context];

   //     self.fbo = [[VSFrameBufferObject alloc] initWithSize:size];
   //     self.qcRenderer = [[QCRenderer alloc] initWithOpenGLContext:self.context pixelFormat:self.pixelFormat file:path];

    }
    return self;
}

- (GLuint)renderAtTme:(double)time{
    
    time /= 1000;
    /*
    CGLLockContext([[self context] CGLContextObj]);
    
	[[self context] makeCurrentContext];
    
   // glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glViewport(0, 0, self.fbo.size.width,self.fbo.size.height);
    
    [self.fbo bind];

   // glClearColor(0, 0, 0, 0);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);    
    
    [self.qcRenderer renderAtTime:time arguments:nil];
    

    [[self context] flushBuffer];
    [self.fbo unbind];
    CGLUnlockContext([[self context] CGLContextObj]);
    
    return self.fbo.texture;
     */
    
   // CGLContextObj			cgl_ctx = [self.context CGLContextObj]; //By using CGLMacro.h there's no need to set the current OpenGL context
    [[self context] makeCurrentContext];

    glClearColor(0.25, 0.25, 0.25, 0.25);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if(self.pBufferRenderer) {
		[self.pBufferRenderer updateTextureForTime:time];
	//	glEnable([self.pBufferRenderer textureTarget]);
	//	glBindTexture([self.pBufferRenderer textureTarget], [_pBufferRenderer textureName]);
	//	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	}
	else
    {
        glColor4f(1.0, 1.0, 1.0, 1.0);
        NSLog(@"blablabla");
    }
    
    [self.context flushBuffer];

    return [self.pBufferRenderer textureName];
}

- (GLuint) texture{
    //return self.fbo.texture;
    return [_pBufferRenderer textureName];
}

-(void) setPublicInputsWithValues:(NSDictionary *)inputValues{
    for(id key in inputValues){
        if (key) {
            id value = [inputValues objectForKey:key];
            if(value){
                if([self.pBufferRenderer.renderer.inputKeys containsObject:key]){
                    [self.pBufferRenderer.renderer setValue:value forInputKey:key];
                }
            }
        }
    }
}

@end
