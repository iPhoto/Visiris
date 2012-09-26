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

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reshape)
													 name:NSViewGlobalFrameDidChangeNotification
												   object:self];
    }
    return self;
}

-(void) setFrameProportionally:(NSRect) frameRect{
    [super setFrame:frameRect];
}

-(void) viewDidMoveToWindow{
    [super viewDidMoveToWindow];
    if ([self window] == nil)
        [self.openGLContext clearDrawable];
}

- (void)setFrame:(NSRect)frameRect{
    //DEAR EDI, LET THIS DRIN
}

- (void) reshape{
	// This method will be called on the main thread when resizing, but we may be drawing on a secondary thread through the display link
	// Add a mutex around to avoid the threads accessing the context simultaneously
	CGLLockContext([[self openGLContext] CGLContextObj]);
    
    glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
    // NSLog(@"glview frame size: %@", NSStringFromSize([self frame].size));
    // NSLog(@"glview bounds size: %@", NSStringFromSize([self bounds].size));
    
	[[self openGLContext] update];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

@end
