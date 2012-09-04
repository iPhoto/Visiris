//
//  VSTrackHolderView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimelineContentView;

/**
 * Protocoll defining how the VSTrackHolderView talks to its deleage about the NSRulerMarker representing the playhead.
 */
@protocol VSTrackHolderViewDelegate <NSObject>

/**
 * Called when the playhead marker started to be dragged around
 * @param playheadMarker The maker which should be moved aroud
 * @param aView NSView the playhead marker is placed in
 * @return If YES the playhead marker starts moving, otherwise not
 */
-(BOOL) shouldMoveMarker:(NSRulerMarker*) marker inTrackHolderView:(VSTimelineContentView*) trackHolderView;

/**
 * Called after the playheadMakrer was moved
 * @param playheadMarker The maker that was moved
 * @param aView NSView the playhead marker is placed in
 */
-(void) didMoveRulerMarker:(NSRulerMarker*) marker inTrackHolderView:(VSTimelineContentView*) trackHolderView;

/**
 * Called before the playheadMakrer is moved
 * @param playheadMarker The maker that will be movd
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants be moved to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) willMoveRulerMarker:(NSRulerMarker*) marker inTrackHolderView:(VSTimelineContentView*) trackHolderView toLocation:(CGFloat) location;

/**
 * Called before the playheadMakrer jumps to the given location moved
 * @param playheadMarker The maker that will jump
 * @param aView NSView the playhead marker is placed in
 * @param location Location the playhead marker wants to jump to
 * @return Location the playhead marker will be moved too
 */
-(CGFloat) mouseDownOnRulerView:(NSRulerView*) rulerView atLocation:(CGFloat) location;


@end


@class VSPlayheadMarker;

/**
 * Subclass of NSView holding views representing the tracks of the timeline. Besides responsible for the playhead marker and the horizontal rulerview
 */
@interface VSTimelineContentView : NSView

/** Delegate VSTrackHolderView communicates like defined in VSPlayHeadRulerMarkerDelegate*/
@property id<VSTrackHolderViewDelegate> trackHolderViewDelegate;

/**
 * Updates the guideline for the given location
 * @param location Location the guidelin is updated for
 */
-(void) moveGuidelineToPosition:(CGFloat) location;

@end
