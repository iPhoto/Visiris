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

/**
 * Called when a VSTimelineObjectView was selected by the user on the timeline
 * @param timelineObjectProxy VSTimelineObjectProxy the clicked VSTimelineObjectView represents
 * @return YES if the VSTimelineObjectView is allowed to get selected, NO otherwise
 */
-(BOOL) timelineObjectProxyWillBeSelected:(VSTimelineObjectProxy*) timelineObjectProxy;

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
 * Called during a Drag and Drop Operation when the VSTimelineObjectProxy is dragged from the fromPosition to the toPosition
 * @param timelineObjectViewController VSTimelineObjectViewController which view is dragged
 * @param fromPosition NSPoint the view of the VSTimelineObjectViewController is dragged from.
 * @param toPosition NSPoint the view of the VSTimelineObjectViewController is dragged to.
 */
-(void) timelineObjectIsDragged:(VSTimelineObjectViewController*) timelineObjectViewController fromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

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


@end

/**
 * VSTimelineObjectViewController is responsible for displaying a VSTimelineObjectProxy representing a VSTimelineObject.
 */
@interface VSTimelineObjectViewController : NSViewController<VSTimelineObjectViewDelegate>

/** Called according to VSTimelineObjectControllerDelegate protocoll */
@property id<VSTimelineObjectControllerDelegate> delegate;

/** VSTimelineObjectProxy of the VSTimelineObject the VSTimelineObjectViewController represents*/
@property (strong) VSTimelineObjectProxy* timelineObjectProxy;

/** Indicates wheter the view of VSTimelineObjectViewController is intersected by an other VSTimelineObjectViewController's view while it is dragged around. */
@property BOOL intersected;

/** Area where the VSTimelineObjectViewController's view is intersected */
@property NSRect intersectionRect;

/** Indicates wheter the intersection started from left or not */
@property BOOL enteredLeft;


/** Indicates wheter the VSTimelineObjectViewController's VSTimelineObjectProxy is only a temporary object on the track. */
@property BOOL temporary;


-(id) initWithDefaultNib;


#pragma mark - Methods

/**
 * Updates the pixelTimeRatio-property and changes the frame of it's view according to new pixelTimeRatio based on its VSProjectItemProxy's startTime and duration.
 * @param newPixelTimeRatio New pixel-time-ratio
 */
-(void) changePixelTimeRatio:(double) newPixelTimeRatio;

@end
