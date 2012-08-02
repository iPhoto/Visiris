//
//  VSTimelineScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Cocoa/Cocoa.h>

#import "VSTrackHolderView.h"

@class VSTimelineScrollView;



/**
 * Protocoll defining how the VSTrackHolderView talks to its deleage about the NSRulerMarker representing the playhead.
 */
@protocol VSPlayHeadRulerMarkerDelegate <NSObject>

/**
 * Called when the playhead marker started to be dragged around
 * @param playheadMarker The maker which should be moved aroud
 * @param aView NSView the playhead marker is placed in
 * @return If YES the playhead marker starts moving, otherwise not
 */
-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

/**
 * Called after the playheadMakrer was moved
 * @param playheadMarker The maker that was moved
 * @param aView NSView the playhead marker is placed in
 */
-(void) didMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

/**
 * Called before the playheadMakrer is moved
 * @param playheadMarker The maker that will be movd
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants be moved to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView toLocation:(CGFloat) location;

/**
 * Called before the playheadMakrer jumps to the given location moved
 * @param playheadMarker The maker that will jump
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants to jump to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) playHeadRulerMarker:(NSRulerMarker*) playheadMarker willJumpInContainingView:(NSView*) aView toLocation:(CGFloat) location;


@end







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


@class VSTrackLabel;


/**
 * Subclass of NSScrollView. Used for scrollView in the timelineView to handle the interaction with the scrool wheel differently
 */
@interface VSTimelineScrollView : NSScrollView<VSTrackHolderViewDelegate>

@property VSTrackHolderView *trackHolderView;

@property double pixelTimeRatio;

@property (readonly)float playheadMarkerLocation;

/** Delegate the class communicates with as defined in VSTimelineScrollViewZoomingDelegate */
@property id<VSTimelineScrollViewZoomingDelegate> zoomingDelegate;

/** Delegate VSTrackHolderView communicates like defined in VSPlayHeadRulerMarkerDelegate*/
@property id<VSPlayHeadRulerMarkerDelegate> playheadMarkerDelegate;

/**
 * Moves the marker representing the playHead to the given location in the horizontal rulerView
 * @param location Loction in the horizontal rulverView the playhead marker should be moved to
 */
-(void) movePlayHeadMarkerToLocation:(CGFloat) location;

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel;

-(void) addTrackView:(NSView*) aTrackView;

@end
