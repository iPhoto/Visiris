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

@interface VSPreviewOpenGLView : NSView <NSCoding>

@property (strong) NSOpenGLContext          *openGLContext;
@property (strong) NSOpenGLPixelFormat      *pixelFormat;
@property (assign) GLuint                   texture;

- (id) initWithFrame:(NSRect)frameRect;
- (void)initOpenGLWithSharedContext:(NSOpenGLContext *)openGLContext;
-(void) setFrameProportionally:(NSRect) frameRect;

- (void)drawView;

@end
