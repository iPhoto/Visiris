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



//for testing only
@property VSPlaybackController *playBackcontroller;

@property (strong) NSOpenGLContext *openGLContext;
@property (strong) NSOpenGLPixelFormat* pixelFormat;
@property (assign) CVDisplayLinkRef displayLink;
@property GLuint texture;
//TODO controller?
//@property (weak) OpenGLViewController *controller;

- (id) initWithFrame:(NSRect)frameRect;
- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context;
- (void) drawView;
- (void) startAnimation;


@end
