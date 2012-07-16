//
//  VSTimelineScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Cocoa/Cocoa.h>

@class VSTimelineScrollView;

/**
 * Protocoll defining how the VSTimelineScrollView communicates with its zoomingDelegate.
 */
@protocol VSTimelineScrollViewZoomingDelegate <NSObject>

/**
 * Called when scroll wheel is moved and the option-key is pressed or when pinch-zoom on the trackpad is performed. Informs the delegate of VSTimelineScrollView about the zooming operation.
 * @param scrollView VSTimelineScrollView wanting the zoom operation
 * @param amount Amount to zoom
 * @param mousePosition Current position of the mouse
 */
-(void) timelineScrollView:(VSTimelineScrollView*) scrollView wantsToBeZoomedAccordingToScrollWheel:(float) amount atPosition:(NSPoint) mousePosition;

@end

/**
 * Subclass of NSScrollView. Used for scrollView in the timelineView to handle the interaction with the scrool wheel differently
 */
@interface VSTimelineScrollView : NSScrollView
/** Delegate the class communicates with as defined in VSTimelineScrollViewZoomingDelegate */
@property id<VSTimelineScrollViewZoomingDelegate> zoomingDelegate;
@end
