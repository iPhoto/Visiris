//
//  VSTimelineObjectPropertiesView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSFrameResizingDelegate.h"

@interface VSTimelineObjectPropertiesView : NSView

@property id<VSFrameResizingDelegate> resizingDelegate;

@end
