//
//  VSTimelineObjectView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimelineObjectView;

/**
 * Protocol for VSTimelineObjectViewDelegates. Methods are invoked by VSTimelineObjectView
 */
@protocol VSTimelineObjectViewDelegate <NSObject>

/**
 * Called by VSTimelineObjectView when i got Selected
 * @param timelineObjectview The View invoked the method.
 */
-(void) timelineObjectViewWasClicked:(VSTimelineObjectView*) timelineObjectView;

/**
 * Called everytime the position of the VSTimelineObjectView has been changed during a dragging-operation
 * @param timelineObjectView VSTimelineObjectView that is dragged.
 * @param oldPosition NSPoint the VSTimelineObjectView was dragged from.
 * @param newPosition NSPoint the VSTimelineObjectView will be dragged to.
 */
-(NSPoint) timelineObjectViewWillBeDragged:(VSTimelineObjectView*) timelineObjectView fromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

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

-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectView*) timelineObjectView;

-(NSRect) timelineObjectWillResize:(VSTimelineObjectView*) timelineObjectView fromFrame:(NSRect) oldFrame toFrame:(NSRect) newFrame;

-(void) timelineObjectDidStopResizing:(VSTimelineObjectView*) timelineObjectView;

@end

@class VSTimelineObject;

/**
 * View-Representation of an object on the timeline
 * 
 */
@interface VSTimelineObjectView : NSView

/** Delegate that is called like definend in VSTimelineObjectViewDelegate Protocol */
@property id<VSTimelineObjectViewDelegate> delegate;

/** if YES, the VSTimelineObjectView is drawn as selected */
@property BOOL selected;

/** if YES the VSTimelineObjectView intersectionRect is drawn */
@property BOOL intersected;

/** Area of the VSTimelineObjectView that's intersected by another VSTimelineObjectView */
@property NSRect intersectionRect;

/** If yes, the view is drawn differently */
@property BOOL temporary;

@end
