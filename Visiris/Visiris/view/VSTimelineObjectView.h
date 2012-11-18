//
//  VSTimelineObjectView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSCoreServices.h"

@class VSTimelineObjectView;

/**
 * Protocol for VSTimelineObjectViewDelegates. Methods are invoked by VSTimelineObjectView
 */
@protocol VSTimelineObjectViewDelegate <NSObject>

/**
 * Called by VSTimelineObjectView when i got Selected
 * @param timelineObjectview The View invoked the method.
 */
-(void) timelineObjectViewWasClicked:(VSTimelineObjectView*) timelineObjectView withModifierFlags:(NSUInteger) modifierFlags;

/**
 * Called when the VSTimelineObjectView has stopped it's dragging operation
 * @param timelineObjectView VSTimelineObjectView which has stopped it's dragging-operation
 */
-(void) timelineObjectViewWasDragged:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called when the VSTimelineObjectView will start a dragging operation
 * @param timelineObjectView VSTimelineObjectView that will be dragged
 * @return If YES the timelineObjectView is allowed to be dragged, otherweise not. !!!Return value not used by now
 */
-(BOOL) timelineObjectViewWillStartDragging:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called when the VSTimelineObjectView's dragging operation has ended.
 * @param timelineObjectView VSTimelineObjectView the dragging operation has ended of.
 */
-(void) timelineObjectDidStopDragging:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called when the VSTimelineObjectView wants to start a resizing-operation. Depending on the returned BOOL value the VSTimelineObjectView is allowed to do so or not.
 * @param timelineObjectView VSTimelineObjectView that wants to start the resizing-operation
 * @return If YES the VSTimelineObjectView is allowed to resize, otherwise not.
 */
-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called after a VSTimelineObjectView was resized
 * @param timelineObjectView VSTimelineObjectView that was resized
 */
-(void) timelineObjectViewWasResized:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called when the VSTimelineObjectView finished it's resize-operation
 * @param timelineObjectView VSTimelineObjectView that finished it's resize-operation
 */
-(void) timelineObjectDidStopResizing:(VSTimelineObjectView*) timelineObjectView;

-(NSDragOperation) draggingOperationWithDraggingInfo:(id<NSDraggingInfo>) draggingInfo hasEnteredTimelineObjectView:(VSTimelineObjectView*) timelineObjectView;

-(void) draggingOperationWithDraggingInfo:(id<NSDraggingInfo>) draggingInfo hasExitedTimelineObjectView:(VSTimelineObjectView*) timelineObjectView;

-(BOOL) draggingInfo:(id<NSDraggingInfo>) draggingInfo isDroppedOnTimelineObjectView:(VSTimelineObjectView*) timelineObjectView;

-(void) mouseUpOnTimelineObjectView:(VSTimelineObjectView*) timelineObjectView;

@optional

/**
 * Called before a VSTimelineObjectView is resized.
 * @param timelineObjectView VSTimelineObjectView that will be resized.
 * @param fromFrame Current frame of the VSTimelineObjectView
 * @param toFrame Frame the VSTimelineObjectView wants to be resized to.
 * @return NSRecte the VSTimelineObjectView's frame will be set to
 */
-(VSDoubleFrame) timelineObjectWillResize:(VSTimelineObjectView*) timelineObjectView fromFrame:(VSDoubleFrame) oldFrame toFrame:(VSDoubleFrame) newFrame;

/**
 * Called everytime the position of the VSTimelineObjectView has been changed during a dragging-operation
 * @param timelineObjectView VSTimelineObjectView that is dragged.
 * @param oldPosition NSPoint the VSTimelineObjectView was dragged from.
 * @param newPosition NSPoint the VSTimelineObjectView will be dragged to.
 * @param mousePosition Current position of the mouse
 */
-(NSPoint) timelineObjectViewWillBeDragged:(VSTimelineObjectView*) timelineObjectView fromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition forMousePosition:(NSPoint) currentMousePosition;

@end


@class VSTimelineObject;

/**
 * View-Representation of an object on the timeline
 * 
 */
@interface VSTimelineObjectView : NSView<NSDraggingDestination>

/** Delegate that is called like definend in VSTimelineObjectViewDelegate Protocol */
@property (weak) id<VSTimelineObjectViewDelegate> delegate;

/** if YES, the VSTimelineObjectView is drawn as selected */
@property (assign) BOOL selected;

/** If yes, the view is drawn differently */
@property (assign) BOOL temporary;

/** If YES the view is moved on mouseDragged-Event */ 
@property (assign) BOOL moving;

/** if YES the view is hidden */
@property (assign) BOOL inactive;

/** Frame of VSTimelineObjectView as VSDoubleFrame */
@property (assign) VSDoubleFrame doubleFrame;

/**
 * Crates a new Layer for an intersection with the view.
 *
 * @param intersection Size and origin of the newly created intersection-layer
 */
-(CALayer*) addIntersectionLayerForRect:(NSRect) intersection;

/**
 * Removes the given layer from the view
 *
 * @param intersectionLayer Layer displaying an intersection to be removed from the view
 */
-(void) removeIntersectionLayer:(CALayer*) intersectionLayer;
@end
