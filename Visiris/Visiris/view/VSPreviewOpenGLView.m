//
//  VSPreviewOpenGLView.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <OpenGL/glu.h>

#import "VSPreviewOpenGLView.h"
#import "VSCoreServices.h"
#import "VSPlaybackController.h"

@implementation VSPreviewOpenGLView
@synthesize openGLContext=_openGLContext,pixelFormat,displayLink;
@synthesize texture = _texture;

@synthesize playBackcontroller = _playBackcontroller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"initWithFrame");
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(reshape) 
													 name:NSViewGlobalFrameDidChangeNotification
												   object:self];
        
    }
    
    return self;
}

- (void)initOpenGLWithSharedContext:(NSOpenGLContext *)openGLContext
{
    NSOpenGLPixelFormatAttribute attribs[] =
    {
		kCGLPFAAccelerated,
		kCGLPFANoRecovery,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
		0
    };
	
    pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
	
    if (!pixelFormat)
		NSLog(@"No OpenGL pixel format");
	
	// NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
	_openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:openGLContext];
	
    [[self openGLContext] makeCurrentContext];
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
    
    [self setupDisplayLink];
}


- (void)lockFocus
{
    NSOpenGLContext* context = [self openGLContext];
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    [context makeCurrentContext];
}

-(void) viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] == nil)
        [_openGLContext clearDrawable];
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
    @autoreleasepool {
        [self.playBackcontroller renderFramesForCurrentTimestamp];
        [self drawView];
        return kCVReturnSuccess;
    }
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge VSPreviewOpenGLView*)displayLinkContext getFrameForTime:outputTime];
    
    return result;
}

- (void) setupDisplayLink
{
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
	// Ignore if the display link is still running
	if (!CVDisplayLinkIsRunning(displayLink))
    {
		[self drawView];    
    }
    
}

- (void) reshape
{
	// This method will be called on the main thread when resizing, but we may be drawing on a secondary thread through the display link
	// Add a mutex around to avoid the threads accessing the context simultaneously
	CGLLockContext([[self openGLContext] CGLContextObj]);
    
    glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
    // NSLog(@"glview frame size: %@", NSStringFromSize([self frame].size));
    // NSLog(@"glview bounds size: %@", NSStringFromSize([self bounds].size));
    
	[[self openGLContext] update];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void) drawView
{
	// This method will be called on both the main thread (through -drawRect:) and a secondary thread (through the display link rendering loop)
	// Also, when resizing the view, -reshape is called on the main thread, but we may be drawing on a secondary thread
	// Add a mutex around to avoid the threads accessing the context simultaneously
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
	// Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
   
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (self.texture != 0) {        
        glEnable( GL_TEXTURE_2D );
        glBindTexture( GL_TEXTURE_2D, self.texture );
        
       // NSLog(@"view texture: %d", self.texture);
                
        glBegin( GL_QUADS );
        glTexCoord2d(0.0,1.0); glVertex2d(-1.0,-1.0);
        glTexCoord2d(1.0,1.0); glVertex2d(1.0,-1.0);
        glTexCoord2d(1.0,0.0); glVertex2d(1.0,1.0);
        glTexCoord2d(0.0,0.0); glVertex2d(-1.0,1.0);
        glEnd();
        
    }
    
	[[self openGLContext] flushBuffer];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void) startDisplayLink{
	if (displayLink && !CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStart(displayLink);
    
     //DDLogInfo(@"startDisplayLink");
}

- (void)stopDisplayLink{
	if (displayLink && CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStop(displayLink);
    
    //DDLogInfo(@"stopDisplayLink");
}

@end
