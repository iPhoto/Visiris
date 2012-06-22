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

@interface VSQCRenderer()
@property (strong) QCRenderer           *qcRenderer;
@property (strong) NSOpenGLContext      *context;
@property (strong) NSOpenGLPixelFormat  *pixelFormat;
@property (strong) VSFrameBufferObject  *fbo;
@end

@implementation VSQCRenderer
@synthesize qcRenderer          = _qcRenderer;
@synthesize context             = _context;
@synthesize pixelFormat         = _pixelFormat;
@synthesize fbo                 = _fbo;
@synthesize timeLineObjectId    = _timeLineObjectId;
@synthesize trackId             = _trackId;

- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format{
    if (self = [super init]) {
        self.context = context;
        self.pixelFormat = format;
        self.fbo = [[VSFrameBufferObject alloc] initWithSize:size];
        self.qcRenderer = [[QCRenderer alloc] initWithOpenGLContext:self.context pixelFormat:self.pixelFormat file:path];
    }
    return self;
}

- (GLuint)renderAtTme:(double)time{
    time /= 1000;
    CGLLockContext([[self context] CGLContextObj]);
    
	[[self context] makeCurrentContext];

    [self.fbo bind];
    glViewport(0, 0, self.fbo.size.width,self.fbo.size.height);

    [self.qcRenderer renderAtTime:time arguments:nil];
    
    [[self context] flushBuffer];
    [self.fbo unbind];
    
    CGLUnlockContext([[self context] CGLContextObj]);

    return self.fbo.texture;
}

- (NSSize) size{
    return self.fbo.size;
}

- (GLuint) texture{
    NSLog(@"textureID: %d", self.fbo.texture);
    return self.fbo.texture;
}

@end
