//
//  VSTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineScrollView.h"
#import "VSTimelineContentView.h"
#import "VSTimelineView.h"
#import "VSViewMouseEventsDelegate.h"

@interface VSTimelineViewController : NSViewController<VSTimelineViewDelegate, VSPlayHeadRulerMarkerDelegate,VSTimelineScrollViewZoomingDelegate, VSViewMouseEventsDelegate>

@property double pixelTimeRatio;
@property (readonly) double duration;
@property (readonly) float pixelLength;
@property (readonly) VSTimelineScrollView *timelineScrollView;
@property (readonly) double playheadTimePosition;

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

@end
