//
//  VSPreviewView.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSFrameResizingDelegate.h"

@interface VSPreviewView : NSView

@property id<VSFrameResizingDelegate> frameResizingDelegate;

@end
