//
//  VSPlayHeadView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSPlayHeadView;


/**
 * Defines how the VSPlayHeadView talks to its delegate, when the position of the VSPlayHeadView is changed
 */
@protocol VSPlayHeadViewDelegate <NSObject>

/**
 * Called before the position of the VSPlayHeadView is changed.
 * @param playheadView VSPlayHeadView the position will be changed of.
 * @param oldPosition NSPoint where the x-component is the current x-Center of playheadView' frame
 * @param newPosition NSPoint the playheadView' frame origin wants to be changed to. The x-component is the x-Center of playheadView' frame.
 * @return NSPoint the playheadView' frame origin will be changed to. The x-component is the  x-Center of playheadView' frame. 
 */
-(NSPoint) willMovePlayHeadView:(VSPlayHeadView*) playheadView FromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

/**
 * Called after the position of the VSPlayHeadView was changed.
 * @param playHeadView VSPlayHeadView which has been moved.
 */
-(void) didMovePlayHeadView:(VSPlayHeadView*) playheadView;

/**
 * Called before VSPlayHeadView starts a draggin-Operation to be moved.
 * @param playHeadView VSPlayHeadView which wants to be moved.
 * @return YES if the VSPlayHeadView is allowed to be dragged, NO otherwise.
 */
-(BOOL) willStartMovingPlayHeadView:(VSPlayHeadView*) playheadView;

/**
 * Called when a dragging-Operation to move the VSPlayHeadView was exited
 * @param playHeadView VSPlayHeadView which has stopped a draggin-Operation
 */
-(void) didStopMovingPlayHeadView:(VSPlayHeadView*) playheadView;

@end




/**
 * Displays the PlayHead at the top of the timeline. VSPlayHeadView can be dragged around to by the user to change the currently active timestamp. If the playback is started, the VSPlayHeadView is moved along the timeline according to the current timestamp of the playback.
 */
@interface VSPlayHeadView : NSView

/** Height of the knob at the top of the playhead */
@property NSInteger knobHeight;

/** Delegate the VSPlayHeadView communicates like defined in VSPlayHeadViewDelegate-Protocoll */
@property id<VSPlayHeadViewDelegate> delegate;

/** Set to YES if the VSPlayHeadView is allowed to be dragged around */
@property BOOL moving;

/** Position of the mouse when last dragging occured */
@property NSPoint formerMousePosition;

@end
