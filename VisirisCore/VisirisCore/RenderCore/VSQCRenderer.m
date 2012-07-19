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
@property (strong) VSPBufferRenderer    *pBufferRenderer;

@end

@implementation VSQCRenderer
@synthesize qcRenderer          = _qcRenderer;
@synthesize context             = _context;
@synthesize pixelFormat         = _pixelFormat;
@synthesize timeLineObjectId    = _timeLineObjectId;
@synthesize trackId             = _trackId;
@synthesize pBufferRenderer     = _pBufferRenderer;
@synthesize size                = _size;

- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format withTrackID:(NSInteger)trackid{
    if (self = [super init]) {

        _trackId = trackid;
        self.context = context;
        self.pixelFormat = format;
        self.size = size;

        self.pBufferRenderer = [[VSPBufferRenderer alloc] initWithCompositionPath:path textureTarget:GL_TEXTURE_2D textureWidth:size.width textureHeight:size.height openGLContext:self.context];
    }
    return self;
}

- (GLuint)renderAtTme:(double)time{
        
    time /= 1000.0;
    [[self context] makeCurrentContext];

    glClearColor(0.25, 0.25, 0.25, 0.25);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if(self.pBufferRenderer) {
		[self.pBufferRenderer updateTextureForTime:time];
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
