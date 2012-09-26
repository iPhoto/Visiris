//
//  VSTimelineObjectPropertiesView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewResizingDelegate.h"

/**
 * Holds the VSTimelineObjectPropertiesView and the VSAnimationTimelineView for the selected VSTimelineObject 
 */
@interface VSTimelineObjectPropertiesView : NSView

/** Delegate that is informed about changes of the view's frame as definend in VSViewResizingDelegate-Protocoll */
@property id<VSViewResizingDelegate> resizingDelegate;

@end
