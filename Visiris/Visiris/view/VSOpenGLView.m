//
//  VSOpenGLView.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSOpenGLView.h"

#import "VSOutputController.h"
#import <OpenGL/glu.h>

@interface VSOpenGLView()

@end


@implementation VSOpenGLView

@synthesize openGLContext   = _openGLContext;
@synthesize pixelFormat     = _pixelFormat;
@synthesize texture         = _texture;

- (void)setOpenGLWithSharedContext:(NSOpenGLContext *)openGLContext andPixelFrom:(NSOpenGLPixelFormat*) pixelFormat{
    
    self.pixelFormat = pixelFormat;
    
	// NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
	self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:self.pixelFormat shareContext:openGLContext];
	
    [[self openGLContext] makeCurrentContext];
    
    glEnable( GL_TEXTURE_2D );
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

- (void) drawView{
	// This method will be called on both the main thread (through -drawRect:) and a secondary thread (through the display link rendering loop)
	// Also, when resizing the view, -reshape is called on the main thread, but we may be drawing on a secondary thread
	// Add a mutex around to avoid the threads accessing the context simultaneously
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
	// Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (self.texture != 0) {
        glBindTexture( GL_TEXTURE_2D, self.texture );
        
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

- (void)lockFocus{
    NSOpenGLContext* context = [self openGLContext];
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    [context makeCurrentContext];
}

- (void) drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
	// Ignore if the display link is still running
    //	if (!CVDisplayLinkIsRunning(displayLink))
    [self drawView];
}

@end
