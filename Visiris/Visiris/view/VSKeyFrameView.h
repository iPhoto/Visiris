//
//  VSKeyFrameView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewMouseEventsDelegate.h"


/**
 * Subclass of NSView representing one VSKeyFrame of an VSAnimation.
 *
 * VSKeyFrameView's are subViews of VSAnimationTrackView's and can be clicked and dragged around.
 */
@interface VSKeyFrameView : NSView

/** Delegate VSKeyFrameView informs about occuring mouse-Events in that mouseDown and mouseDragged */
@property (weak) id<VSViewMouseEventsDelegate> mouseDelegate;

/** Indicates wheter the View is currently being moved around. According to the moving-State the view is drawn differently */
@property BOOL moving;

/** Indicates wheter the View is currently being selected According to the selected-State the view is drawn differently */
@property BOOL selected;

@end
