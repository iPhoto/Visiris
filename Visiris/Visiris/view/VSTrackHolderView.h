//
//  VSTrackHolderView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

@end

/**
 * Subclass of NSView holding views representing the tracks of the timeline. Besides responsible for the playhead marker and the horizontal rulerview
 */
@interface VSTrackHolderView : NSView

/** Delegate VSTrackHolderView communicates like defined in VSPlayHeadRulerMarkerDelegate*/
@property id<VSPlayHeadRulerMarkerDelegate> playheadMarkerDelegate;

/** 
 * Moves the marker representing the playHead to the given location in the horizontal rulerView
 * @param location Loction in the horizontal rulverView the playhead marker should be moved to
 */
-(void) setPlayHeadMarkerToLocation:(CGFloat) location;

@end
