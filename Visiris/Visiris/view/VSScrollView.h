//
//  VSScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 11.09.12.
//
//

#import <Cocoa/Cocoa.h>

/**
 * Protocoll the VSScrollView informs about scrolling-Events
 */
@protocol VSScrollViewScrollingDelegate <NSObject>

/**
 * Informs about an ongoing scrolling-Event of the scrollView
 * @param scrollView NSScrollView the scrollEvent happens in
 * @param scrollEvent NSEvent describing the ongoing scrollingEvent
 * @return If YES the scrollView will be scrolled according to the event.
 */
-(BOOL) scrollView:(NSScrollView*) scrollView wantsToBeScrolledByScrollWheelEvent:(NSEvent*) scrollEvent;

/**
 * Called when the scrollViews bounds have been changed
 * @param scrollView NSScrollView the bounds have been changed of
 * @param fromBounds NSRect storing the bounds of the scrollView before the change
 * @param toBounds NSRect sotring the current bounds of the scrollView
 */
-(void) scrollView:(NSScrollView*) scrollView changedBoundsFrom:(NSRect) fromBounds to:(NSRect) toBounds;

@end


/**
 * Subclass of NSScrollView which informs its scrollingDelegate if any scrolling activity are happening as definend in VSScrollingViewDelegateProtocoll
 */
@interface VSScrollView : NSScrollView

/** Delegate which is informed about scrolling activities according to VSScrollingViewScrollingDelegate*/
@property id<VSScrollViewScrollingDelegate> scrollingDelegate;

/**
 * Changes the origin of the view's bounds without notifying it's delegate about the change
 * @param boundsOrigin NSPoint the origin of the view's bounds will be changed to
 */
-(void) setBoundsOriginWithouthNotifiying:(NSPoint) boundsOrigin;

@end
