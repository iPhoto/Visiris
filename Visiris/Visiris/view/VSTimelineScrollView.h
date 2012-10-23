//
//  VSTimelineScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Cocoa/Cocoa.h>

#import "VSScrollView.h"
#import "VSTimelineScrollViewDocumentView.h"

@class VSTimelineScrollView;


/**
 * Protocoll defining how the VSTrackHolderView talks to its deleage about the NSRulerMarker representing the playhead.
 */
@protocol VSPlayHeadRulerMarkerDelegate <NSObject>

@optional

/**
 * Called when the playhead marker started to be dragged around
 *
 * @param playheadMarker The maker which should be moved aroud
 * @param aView NSView the playhead marker is placed in
 * @return If YES the playhead marker starts moving, otherwise not
 */
-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

/**
 * Called before the playheadMakrer is moved
 *
 * @param playheadMarker The maker that will be movd
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants be moved to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView toLocation:(CGFloat) location;

/**
 * Called before the playheadMakrer jumps to the given location moved
 *
 * @param playheadMarker The maker that will jump
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants to jump to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) playHeadRulerMarker:(NSRulerMarker*) playheadMarker willJumpInContainingView:(NSView*) aView toLocation:(CGFloat) location;

@optional

/**
 * Call after the playheadMarker jump to a new Location
 * 
 * @param playheadMarker NSRulerMarker representing the Playhead of the timeline
 * @param aView NSView holding the playheadMarker
 * @param location Location the given playheadMarker has jumped to
 */
-(void) playHeadRulerMarker:(NSRulerMarker *)playheadMarker didJumpInContainingView:(NSView *)aView toLocation:(CGFloat)location;

/**
 * Called after the playheadMakrer was moved
 *
 * @param playheadMarker The maker that was moved
 * @param aView NSView the playhead marker is placed in
 */
-(void) didMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

@end






/**
 * Protocoll defining how the VSTimelineScrollView communicates with its zoomingDelegate.
 */
@protocol VSTimelineScrollViewZoomingDelegate <NSObject>

/**
 * Called when scroll wheel is moved and the option-key is pressed or when pinch-zoom on the trackpad is performed. Informs the delegate of VSTimelineScrollView about the zooming operation.
 *
 * @param scrollView VSTimelineScrollView wanting the zoom operation
 * @param amount Amount to zoom
 * @param mousePosition Current position of the mouse
 */
-(NSRect) timelineScrollView:(VSTimelineScrollView*) scrollView wantsToBeZoomedAccordingToScrollWheel:(float) amount atPosition:(NSPoint) mousePosition forCurrentFrame:(NSRect) currentFrame;

/**
 * Called when the timeline was zoomed.
 *
 * @param scrollView VSTimelienScrollView that was zoomed
 * @param position NSPoint in the scrollViews coordinates where the zoom-operation did happen
 */
-(void) timelineScrollView:(VSTimelineScrollView*) scrollView wasZoomedAtPosition:(NSPoint) position;

@end









/**
 * Subclass of NSScrollView. Used for scrollView in the timelineView to handle the interaction with the scrool wheel differently
 */
@interface VSTimelineScrollView : VSScrollView<VSTrackHolderViewDelegate>

/** DocumentView of the scrollView */
@property (strong) VSTimelineScrollViewDocumentView *trackHolderView;

/** Ratio between the width of the timelineView and the duration of the VSTimeline it's reperesenting */
@property double pixelTimeRatio;

/** Returns the current markerLocation of the playheadMarker */
@property (readonly)float playheadMarkerLocation;

/**
 * The visible widht of the track holder is neccessary to calculation the pixelItemRation
 * @return The visble width of scvTrackHolder
 */
@property (readonly) float visibleTrackViewsHolderWidth;

/** Delegate the class communicates with as defined in VSTimelineScrollViewZoomingDelegate */
@property (strong) id<VSTimelineScrollViewZoomingDelegate> zoomingDelegate;

/** Delegate VSTrackHolderView communicates like defined in VSPlayHeadRulerMarkerDelegate*/
@property (strong) id<VSPlayHeadRulerMarkerDelegate> playheadMarkerDelegate;

/** Current width of the trackHolder. Properties area usually overriden by the Childclasses of VSTimelineScrollView. */
@property float trackHolderWidth;

/** Thicknes of the horizontalRuler displaying the timecodes */
@property (readonly) CGFloat timelecodeRulerThickness;

/**
 * Moves the marker representing the playHead to the given location in the horizontal rulerView
 * @param location Loction in the horizontal rulverView the playhead marker should be moved to
 */
-(void) movePlayHeadMarkerToLocation:(CGFloat) location;


/**
 * Adds the given NSView as a Track of the Timeline.
 *
 * Adds the view as SubView of the ScrollViews document view and resizes its frame according to the sizes of all tracks fo the scrollView
 * @param aTrackView NSView to be added as track of the timeline
 */
-(void) addTrackView:(NSView*) aTrackView;

@end
