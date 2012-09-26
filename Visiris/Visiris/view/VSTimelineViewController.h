//
//  VSTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineScrollView.h"
#import "VSTimelineScrollViewDocumentView.h"
#import "VSTimelineView.h"
#import "VSViewMouseEventsDelegate.h"
#import "VSViewResizingDelegate.h"

@class VSPlayHead;


/**
 * VSTimelineViewController is the base-class for all TimelineViewControllers of the project
 *
 * VSTimelineViewController holds a various number of VSTrackViewController representing the VSTracks of the VSTimeline and acts as delegate for the VSTrackViewControllers.
 * !!!!!!Please add more here
 */
@interface VSTimelineViewController : NSViewController<VSViewResizingDelegate, VSViewMouseEventsDelegate, VSViewKeyDownDelegate, VSPlayHeadRulerMarkerDelegate,VSTimelineScrollViewZoomingDelegate>

/** Ratio between the pixel-length of the timeline and the the duration of the timeline milliseconds */
@property double pixelTimeRatio;

/** Duration of the timeline, neccessary for computing the pixelTimeRatio. Property must be implemented in child class. */
@property (readonly) double duration;

/** Length of the timelien in pixel, neccessary for computing the pixelTimeRatio. Property must be implemented in child class. */
@property (readonly) float pixelLength;

/** Subclass of NSScrollView holding the timeline's tracks. Property must be implemented in child class. */
@property (weak) IBOutlet VSTimelineScrollView *scrollView;

/** CurrentTimePosition of the timeline's playhead. Property must be implemented in child class. */
@property (readonly) double playheadTimePosition;

/** Playhead of the the timeline. Property must be implemented in child class. */
@property (readonly,weak) VSPlayHead *playhead;

/** Current location of the NSRulerMarker used as representaiton of the timeline's playhead. Property must be implemented in child class. */
@property (readonly) float currentPlayheadMarkerLocation;

#pragma mark - Protected Methods

/**
 * Translates the given pixel value to a timestamp according to the pixelTimeRation
 * @param pixelPosition Value in pixels the timestamp is computed for
 * @return Timestamp for the given pixel position
 */
-(double) timestampForPixelValue:(double) pixelPosition;

/**
 * Transletes the given timestamp to a pixel value according to the pixelTimeRation
 * @param timestamp Timestamp the pixel position is computed for
 * @return Pixelposition for the given Timestamp
 */
-(double) pixelForTimestamp:(double) timestamp;

/**
 * Updates the ratio between the length of trackholder's width and the duration of the timeline
 */
-(void) computePixelTimeRatio;

/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange;

/**
 * Sets the plahead marker according to the playhead's currentposition on the timeline
 */
-(void) setPlayheadMarkerLocation;

/**
 * Computes the new currentTimePosition of the timeline's playhead after the playhead-marker would have been moved the default distance, updates the currentTimePosition and sets the playhead's jumping-flag to YES
 * @param forward Indicates wheter the playhead is moved left or right
 */
-(void) letPlayheadJumpOverTheDefaultDistanceForward:(BOOL) forward;

/**
 * If the given location the Playhead has been moved to is outside of the visibleRect of the scrollView the view is scrolled.
 *
 *@param newLocation Location the Playhead has been moved to
 */
-(void) scrollIfNewLocationOfPlayheadIsOutsideOfVisibleRect:(float) newLocation;


/**
 * Computes the new currentTimePosition of the timeline's playhead after the playhead-marker would have been moved the given distance, updates the currentTimePosition and sets the playhead's jumping-flag to YES
 * @param distance Distance the Playhead will be moved
 */
-(void) letPlayheadJumpOverDistance:(float) distance;

@end
