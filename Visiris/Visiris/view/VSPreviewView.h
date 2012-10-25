//
//  VSPreviewView.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSViewResizingDelegate.h"

/**
 * Main view in VSPrevieView.xib. Holds the VSPreviewOpenGLView and informs its delegate if the view's frame has been resized
 */
@interface VSPreviewView : NSView

/** Delegate which is informed about changes of the view's frame ad described in VSViewResizingDelegate-Protocoll */
@property (weak) id<VSViewResizingDelegate> frameResizingDelegate;

@end
