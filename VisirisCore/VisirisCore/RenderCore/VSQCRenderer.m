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

/** The class given from the Quartzframework for rendering patches */
@property (strong) QCRenderer           *qcRenderer;

/** OpenGLcontext */
@property (strong) NSOpenGLContext      *context;

/** Pixelformat for the OpenglContext */
@property (strong) NSOpenGLPixelFormat  *pixelFormat;

/** Needed for offscreen rendering */
@property (strong) VSPBufferRenderer    *pBufferRenderer;

/** The Path of the Renderer on the Disk */
@property (strong) NSString             *path;

/** NSNumber with int - OpenGLTexture */
@property (strong) NSNumber              *texture;


@end


@implementation VSQCRenderer
@synthesize qcRenderer          = _qcRenderer;
@synthesize context             = _context;
@synthesize pixelFormat         = _pixelFormat;
@synthesize timeLineObjectId    = _timeLineObjectId;
@synthesize trackId             = _trackId;
@synthesize pBufferRenderer     = _pBufferRenderer;
@synthesize size                = _size;
@synthesize path                = _path;
@synthesize texture             = _texture;

#pragma Mark - Init

- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format withTrackID:(NSInteger)trackid withTexture:(NSNumber *)texture{
    if (self = [super init]) {

        _trackId = trackid;
        self.context = context;
        self.pixelFormat = format;
        self.size = size;
        self.path = path;
        self.texture = texture;

        self.pBufferRenderer = [self createPBufferRenderer];
    }
    return self;
}

#pragma mark - Methods

- (GLuint)renderAtTme:(double)time{
    
    //todo slow
    time /= 1000.0;
    [[self context] makeCurrentContext];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if(self.pBufferRenderer) {
		[self.pBufferRenderer updateTextureForTime:time];
	}
	else
        NSLog(@"ERROR im quartzschassssss");
    
    [self.context flushBuffer];
    
    return [self.pBufferRenderer textureName];
}

- (void)setPublicInputsWithValues:(NSDictionary *)inputValues{
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


- (void)resize:(NSSize)size{
    self.size = size;
    self.pBufferRenderer = [self createPBufferRenderer];
}


#pragma mark - Private Methods

- (VSPBufferRenderer *)createPBufferRenderer{
    return [[VSPBufferRenderer alloc] initWithCompositionPath:self.path
                                                 textureWidth:self.size.width
                                                textureHeight:self.size.height
                                                openGLContext:self.context
                                                  withTexture:self.texture];

}

@end
