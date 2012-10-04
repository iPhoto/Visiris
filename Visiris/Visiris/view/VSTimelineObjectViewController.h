//
//  VSTimelineObjectViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineObjectView.h"

@class VSTimelineObjectProxy;
@class VSTimelineObjectViewController;

/**
 * Protocoll that defines how VSTimelineObjectViewController talks to its delegate 
 *
 */
@protocol VSTimelineObjectControllerDelegate <NSObject>

@required

/**
 * Called when a VSTimelineObjectView was selected by the user on the timeline
 * @param timelineObjectProxy VSTimelineObjectProxy the clicked VSTimelineObjectView represents
 * @return YES if the VSTimelineObjectView is allowed to get selected, NO otherwise
 */
-(BOOL)timelineObjectProxyWillBeSelected:(VSTimelineObjectProxy *)timelineObjectProxy exclusively:(BOOL) exclusiveSelection;

/**
 * Called when the VSTimelineObjectProxy got selected
 * @param timelineObjectProxy VSTimelineObjectProxy that got selected
 */
-(void) timelineObjectProxyWasSelected:(VSTimelineObjectProxy*) timelineObjectProxy;

/**
 * Called when the VSTimelineObjectProxy got unselected
 * @param timelineObjectProxy VSTimelineObjectProxy that got unselected
 */
-(void) timelineObjectProxyWasUnselected:(VSTimelineObjectProxy*) timelineObjectProxy;

/**
 * Called when the view of the VSTimelineObjectViewController has stopped it's dragging operation
 * @timelineObjectViewController VSTimelineObjectViewController of the view which has stopped it's dragging operation
 */
-(void) timelineObjectWasDragged:(VSTimelineObjectViewController*) timelineObjectViewController;

/**
 * Called when a drag-Operation on view of the VSTimelineObjectViewController is started
 * @param timelineObjectViewController VSTimelineObjectViewController on which'S view a drag-Operation will be started.
 * @return YES if the drag-Operation is allowed to start, NO otherwise.
 */
-(BOOL) timelineObjectWillStartDragging:(VSTimelineObjectViewController*) timelineObjectViewController;

/**
 * Called when a drag-Operation on view of the VSTimelineObjectViewController was stopped.
 * @param timelineObjectViewController VSTimelineObjectViewController on which'S view a drag-Operation was stopped.
 * @return YES if the drag-Operation is allowed to start, NO otherwise.
 */
-(void) timelineObjectDidStopDragging:(VSTimelineObjectViewController*) timelineObjectViewController;

/**
 * Called when the view of the VSTimelineObjectViewController wants to start a resize-operation
 * @param timelineObjectViewController VSTimelineObjectViewController of the view that wants to start a resize-operation.
 * @return If YES the view of the VSTimelineObjectViewController is allowed to resize, otherwise not
 */
-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectViewController *)timelineObjectViewController;

/**
 * Called when the view of VSTimelineObjectViewController was resized
 * @param timelineObjectViewController VSTimelineObjectViewController which's view was resized
 */
-(void) timelineObjectProxyWasResized:(VSTimelineObjectViewController *)timelineObjectViewController;

/**
 * Called whene the view of the VSTimelineObjectViewController stop its resize-operation
 * @param timelineObjectViewController VSTimelineObjectViewController whichs' view's operation has been stopped.
 */
-(void) timelineObjectDidStopResizing:(VSTimelineObjectViewController *)timelineObjectViewController;

@optional

/**
 * Called during a Drag and Drop Operation when the view of the VSTimelineObjectViewController is dragged from fromPosition to toPosition.
 * @param timelineObjectViewController VSTimelineObjectViewController that will be dragged.
 * @param newPosition Position the view of the VSTimelineObjectViewController is dragged from
 * @param oldPosition NSPoint the view of the VSTimelineObjectViewController wants to be dragged to
 * @param mousePosition Current position of the mouse
 * @return NSPoint the view of the VSTimelineObjectViewController will be moved to.
 */
-(NSPoint) timelineObjectWillBeDragged:(VSTimelineObjectViewController *)timelineObjectViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition forMousePosition:(NSPoint) mousePosition;

/**
 * Called before the view of the VSTimelineObjectViewController gets resized.
 * @param timelineObjectViewController VSTimelineObjectViewController of the view wich will be resized
 * @param fromFrame Current frame of the view of the VSTimelineObjectViewController
 * @param toFrame Frame the VSTimelineObjectViewController view will be set to
 * @param NSRect the frame of the VSTimelineObjectViewController's view will be set to
 */
-(VSDoubleFrame) timelineObjectWillResize:(VSTimelineObjectViewController *)timelineObjectViewController fromFrame:(VSDoubleFrame)oldFrame toFrame:(VSDoubleFrame)newFrame;
@end






/**
 * VSTimelineObjectViewController is responsible for displaying a VSTimelineObjectProxy representing a VSTimelineObject.
 */
@interface VSTimelineObjectViewController : NSViewController<VSTimelineObjectViewDelegate>

/** Controllers view casted as VSTimelineObjectView */
@property (strong) VSTimelineObjectView *timelineObjectView;

/** Called according to VSTimelineObjectControllerDelegate protocoll */
@property (weak) id<VSTimelineObjectControllerDelegate> delegate;

/** VSTimelineObjectProxy of the VSTimelineObject the VSTimelineObjectViewController represents*/
@property (weak, readonly) VSTimelineObjectProxy* timelineObjectProxy;

/** Indicates wheter the VSTimelineObjectViewController's VSTimelineObjectProxy is only a temporary object on the track. */
@property BOOL temporary;

/** Indicates wheter the views is currently moved */
@property BOOL moving;

/** if YES the timelineObejct is hidden */
@property BOOL inactive;

/** Stores the VSDoubleFrame of VSTimelineObjectViewController's VSTimelineObjectView */
@property VSDoubleFrame viewsDoubleFrame;

/** Stores the VSTimelineObjectViewController which's views intersecting the view of the VSTimelineObjectViewController as VSTimelineObjectIntersection */
@property (strong,readonly) NSMutableDictionary *intersectedTimelineObjectViews;

@property (readonly, weak) VSTimelineObject *timelineObject;

#pragma mark - Init

-(id) initWithDefaultNibAndTimelineObjectProxy:(VSTimelineObjectProxy*) timelineObjectProxy;


#pragma mark - Methods


/**
 * Updates the pixelTimeRatio-property and changes the frame of it's view according to new pixelTimeRatio based on its VSProjectItemProxy's startTime and duration.
 * @param newPixelTimeRatio New pixel-time-ratio
 */
-(void) changePixelTimeRatio:(double) newPixelTimeRatio;

/**
 * Creates a new VSTimelineObjectIntersection for the given parameters and stores it in the intersectedTimelineObjectViews-property
 * @param timelineObjectViewController VSTimelineObjectViewController which's view intersects.
 * @param intersectionRect NSRect defining where on the view the intersetion happens
 */
-(void) intersectedByTimelineObjectView:(VSTimelineObjectViewController*) timelineObjectViewController atRect:(NSRect) intersectionRect;

/**
 * Removes the any intersections for the given VSTimelineObjectViewController from the intersectedTimelineObjectViews-property
 * @param timelineObjectViewController VSTimelineObjectViewController which intersections are removed.
 */
-(void) removeIntersectionWith:(VSTimelineObjectViewController*) timelineObjectViewController;

/**
 * Removes all intersections
 */
-(void) removeAllIntersections;

@end
