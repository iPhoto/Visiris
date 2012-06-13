//
//  VSPreviewOpenGLView.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>

@class VSPlaybackController;

@interface VSPreviewOpenGLView : NSView

@property (strong) VSPlaybackController     *playBackcontroller;
@property (strong) NSOpenGLContext          *openGLContext;
@property (strong) NSOpenGLPixelFormat      *pixelFormat;
@property (assign) CVDisplayLinkRef         displayLink;
@property (assign) GLuint                   texture;

- (id) initWithFrame:(NSRect)frameRect;
- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context;
- (void) drawView;
- (void) startAnimation;

@end
