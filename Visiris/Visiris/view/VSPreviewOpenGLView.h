//
//  VSPreviewOpenGLView.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>
#import "VSOpenGLView.h"

@class VSPlaybackController;

/**
 * ADD DESCRIPTION HERE
 */
@interface VSPreviewOpenGLView : VSOpenGLView

- (id)initWithFrame:(NSRect)frameRect;
- (void)setFrameProportionally:(NSRect) frameRect;

@end
