//
//  VSTrackViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTrackView.h"
#import "VSTimelineObjectViewController.h"

#import "VSCoreServices.h"

@class VSTrack;
@class VSTimelineObjectViewController;
@class VSTrackViewController;
@class VSProjectItemRepresentation;
@class VSTimelineObjectProxy;
@class VSTimelineObject;


/**
 * Delegate Protocoll for TrackViewControllers
 */
@protocol VSTrackViewControllerDelegate <NSObject>


-(void) addDevices:(NSArray*) devices toTimelineObject:(VSTimelineObject*) timelineObject onTrack:(VSTrackViewController*) trackViewController;

/** 
 * Called when a new ProjectItem was added to the TrackView
 *
 * @param trackViewController VSTrackViewController of the VSTrackView the VSTimelineObject will be added to.
 * @param item VSProjectItemRepresentation the VSTimelineObject that will be added is based on
 * @param position NSPoint the VSTimelineObject to be added to
 * @param aWidth Width of he VSTimelineObject to be added to
 * @return The newly created TimelineObject if it was addedd successfully, NO otherwise
 */
-(void) trackViewController:(VSTrackViewController*) trackViewController addTimelineObjectsBasedOnProjectItemRepresentation:(NSArray *)projectItemRepresentations  atPositions:(NSArray*) positionArray withWidths:(NSArray*) widthArray;

/** 
 * Called when an Object that can be added is over a track.
 *
 * @param trackViewController VSTrackViewController of the VSTrackView the VSProjectItemRepresentation is over
 * @param item VSProjectItemRepresentation which is over the VSTrackView
 * @param position NSPoint the VSTimelineObjectProxy will be set for
 * @return The created VSTimelineObjectProxy if it was created successfully, nil otherwise
 */
-(VSTimelineObjectProxy*) trackViewController:(VSTrackViewController*) trackViewController createTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item atPosition:(NSPoint) position;

/**
 * Called before a timelineObjects gets selected
 *
 * @param timelineObjectProxy VSTimelineObjectProxy that wants to be set selected
 * @param trackViewController VSTrackViewController the VSTimelineObjectView representing the timelineObjectProxy is subview of
 * @return YES if the VSTimelineObjectProxy is allowed to get selected, NO otherwise
 */
-(BOOL) timelineObjectProxy:(VSTimelineObjectProxy *) timelineObjectProxy willBeSelectedOnTrackViewController:(VSTrackViewController*) trackViewController exclusively:(BOOL)exclusiveSelection;

/**
 * Called before a TimelineObject is removed from a track
 *
 * @param timelineObjectProxy VSTimelineObjectProxy that will be removed.
 * @param trackViewController VSTrackViewController the timelineObjectProxy will be removed from
 */
-(void) timelineObjectProxies:(NSArray *) timelineObjectProxies wereRemovedFromTrack:(VSTrackViewController*) trackViewController;

/**
 * Called when the view of the VSTrackViewController was clicked.
 *
 * @param trackViewController VSTrackViewController of the view that was clicked
 */
-(void) didClickViewOfTrackViewController:(VSTrackViewController*) trackViewController;

/**
 * Called when a timelineObjectProxy a VSTimelineObjectView represents got unselected.
 *
 * @param trackViewController VSTrackViewController responsible for the VSTimelineObjectView which's VSTimelineObjectProxy got unselected.
 * @param timelineObjectProxy The VSTimelineObjectProxy a VSTimelineObjectView represents got unselected.
 */
-(void) timelineObjectProxy:(VSTimelineObjectProxy *) timelineObjectProxy wasUnselectedOnTrackViewController:(VSTrackViewController*) trackViewController;

/**
 * Called when a timelineObejct wants to be moved to the given position.
 *
 * @param timelineObject VSTimelineObjectViewController's view that wants to change its position
 * @param trackViewController VSTrackViewController holding the VSTimelineObjectViewController's view
 * @param oldPosition Current position of the VSTrackViewController's view
 * @param newPosition Position the VSTrackViewController's view wants to be moved to
 * @param snappingDeltaX Distance to the nearest active snapping point
 * @return NSPoint the VSTimelineObjectViewController's view will be moved to
 */
-(NSPoint) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController WillBeDraggedOnTrack:(VSTrackViewController*) trackViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition withSnappingDeltaX:(float) snappingDeltaX;

/**
 * Called when the timelineObject stored in the VSTimelineObjectViewController needs to be splitted up according to the NSRects in splittingRects
 *
 * @param timelineObjectViewController VSTimelineObjectViewController holding the VSTimelineObejct to be splitted up
 * @param trackViewController VSTrackViewController holding the timelineObjectViewController
 * @param splittingRects NSArray storing NSValues for NSRects defining the areas where the timelineObject will be split up
 * @return YES if the splitting was sucessfully, NO otherwise
 */
-(BOOL) splitTimelineObject:(VSTimelineObjectViewController*) timelineObjectViewController ofTrack:(VSTrackViewController*) trackViewController byRects:(NSArray*) splittingRects;

/**
 * Called to reomve the given timelineObejctViewController from the track
 *
 * @param timelineObjectViewController VSTimelineObjectViewController to be removed from the track
 * @param fromTrack VSTrackViewController the given VSTimelineObjectViewController should be remove from
 * @return YES if the removal was done successfully, NO otherwise
 */
-(BOOL) removeTimelineObject:(VSTimelineObjectViewController*) timelineObjectViewController fromTrack:(VSTrackViewController*) trackViewController;

/**
 * Called when the track wants that the given VSTimelineObjectViewController to be copied to it
 *
 @param timelineObjectViewController VSTimelineObjectViewController to be copied to the given VSTrackViewController
 *@param toTrack VSTrackViewController the given VSTimelineObjectViewController should be copied to
 */
-(void) copyTimelineObject:(VSTimelineObjectViewController*) timelineObjectViewController toTrack:(VSTrackViewController*) trackViewController;



@optional

/**
 * Called when the VSTimelineObjectViewController's view was moved
 *
 * @param timelineObjectViewController VSTimelineObjectViewController which's view was moved
 * @param trackViewController VSTrackViewController holding the VSTimelineObjectViewController's view 
 */
-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController wasDraggedOnTrack:(VSTrackViewController*) trackViewController;

/**
 * Called before the timelineObjectViewController starts to be dragged around on the trackViewController
 *
 * @param timelineObjectViewController VSTimelineObjectViewController which will start dragging
 * @param trackViewController VSTrackViewController holding the given VSTimelineObjectViewController
 */
-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController willStartDraggingOnTrack:(VSTrackViewController*) trackViewController;


/**
 * Called during dragging-operations. Sends the delgate the moved TimelineObject and the current mouse position thus the delgate can check if the mouse is over a different track and the timelineObjects have to been moved to other tracks temporarily 
 *
 * @param timelineObject VSTimelineObjectViewController that was moved and should be checked if it has to be moved temporarily to another track 
 * @param fromTrack VSTrackViewController the timelineObject is currently on
 * @param position Current mouse position
 */
-(void) moveTimelineObjectTemporary:(VSTimelineObjectViewController*) timelineObject fromTrack:(VSTrackViewController*) fromTrack toTrackAtPosition:(NSPoint) position;


/**
 * Called when a timelineObjectProxy a VSTimelineObjectView represents got selected.
 *
 * @param trackViewController VSTrackViewController responsible for the VSTimelineObjectView which's VSTimelineObjectProxy got selected.
 * @param timelineObjectProxy The VSTimelineObjectProxy a VSTimelineObjectView represents got selected.
 */
-(void) timelineObjectProxy:(VSTimelineObjectProxy *) timelineObjectProxy wasSelectedOnTrackViewController:(VSTrackViewController*) trackViewController;


/**
 * Called when the dragging operation of the VSTimelineObjectViewController's view has ended
 *
 * @param timelineObjectViewController VSTimelineObjectViewController which's views draggin operation has ended
 * @param trackViewController VSTrackViewController holding the VSTimelineObjectViewController's view 
 */
-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController didStopDraggingOnTrack:(VSTrackViewController*) trackViewController;


-(BOOL) timelineObject:(VSTimelineObjectViewController*) timelineObjectViewController willStartResizingOnTrack:(VSTrackViewController*) trackViewController;

-(void) timelineObject:(VSTimelineObjectViewController*) timelineObjectViewController didStopResizingOnTrack:(VSTrackViewController*) trackViewController;

-(VSDoubleFrame) timelineObject:(VSTimelineObjectViewController*) timelineObjectViewController willBeResizedFrom:(VSDoubleFrame) oldDoubleFrame to:(VSDoubleFrame) newDoubleFrame onTrack:(VSTrackViewController*) trackViewController;

-(void) timelineObject:(VSTimelineObjectViewController*) timelineObjectViewController wasResizedOnTrack:(VSTrackViewController*) trackViewController;

-(NSArray*) files:(NSArray*) filePaths haveEnteredTrack:(VSTrackViewController*) track;

-(NSArray*) files:(NSArray*) filePaths haveBeenDroppedOnTrack:(VSTrackViewController*) track;

@end



/**
 * Subclass of NSViewController, representing a VSTrack and its VSTimelineObjects.
 *
 * Pleas write more
 */
@interface VSTrackViewController : NSViewController<VSTrackViewDelegate, VSTimelineObjectControllerDelegate>

/**
 * Defines on which side for snapping should be looked for
 */
typedef enum{
    VSSnapLeftSideOnly,
    VSSnapRightSideOnly,
    VSSnapBothSides
    
} VSSnapAtSide;


/** Track the view VSTrackViewController is responsible for */
@property (weak) VSTrack* track;

/** Delegate to called according to VSTrackViewControllerDelegate*/
@property (weak) id<VSTrackViewControllerDelegate> delegate;

/** Pixel Item Ratio as set in VSTimelineViewController */
@property double pixelTimeRatio;




/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView) for the given timeline.
 * @param track The VSTrack the VSTrackViewController represents
 * @return self
 */
-(id) initWithDefaultNibAccordingToTrack:(VSTrack*) track andTrackHeight:(float) height;

/** 
 * Called from VSTimelineViewController when the pixelTimeRatio has been changes 
 * @param newRatio The value the pixelItemRatio was changed to
 */
-(void) pixelTimeRatioDidChange:(double) newRatio;

/**
 * Moves all moveable timelineObjects (selected and temporary timelineObjects) on the track according to the given deltaX
 * @param deltaX Distance the selected timelineObjects are moved
 */
-(void) moveMoveableTimelineObjects:(double) deltaX;

/**
 * Checks if any of the currently moveable timelineObjects (selected and temporary timelineObjects) of the track are in snapping distance to another object when the timelineObejct was moved according to deltaX. If a timlineObject is in snapping distance the additional distance the object has to be moved to be snaped are stored in snappingDeltaX
 * @param deltaX Distance the timelineObejcts will be moved
 * @param snappingDeltaX Additional distance the timelineObjects have to be moved to snap to be snapped to the nearet object in snapping distance.
 * @return YES if the any of the selected timelineObjects is in snapping distance to any other timelineObject of the track, NO otherwise
 */
-(BOOL) computeSnappingXValueForMoveableActiveTimelineObjectsMovedAccordingToDeltaX:(float) deltaX snappingDeltaX:(float*) snappingDeltaX;

/**
 * Detects if any of the moveable timelineObjects (selected and temporary timelineObjects) intersects any of the other timelineObjects on the track
 *
 * If an intersection is found, the VSTimelineObjectViewController of the intersected view is informed about it and the NSRect where the intersection happens is sent to it.
 */
-(void) setTimelineObjectViewsIntersectedByMoveableTimelineObjects;

/**
 * Updates the startTime and duration of the timelineObjectProxy-Property of all currently selected VSTimelineObjectViewControllers according to their views x-origin and width.
 */
-(void) updateActiveMoveableTimelineObjectsAccordingToViewsFrame;

/**
 * Applies the Intersections stored in the intersected timelineObjects like set in setTimelineObjectViewsIntersectedBySelectedTimelineObjects. 
 */
-(void) applyIntersectionToTimelineObjects;

/**
 * Sets the moving-property of all selected VSTimlineObjectView's to NO
 */
-(void) unsetSelectedTimelineObjectsAsMoving;

/**
 * Sets the moving-property of all selected VSTimlineObjectView's to YES
 */
-(void) setSelectedTimelineObjectsAsMoving;

/**
 * Adds a new VSTimelineObjectViewController to self.temporaryTimelineObjectViewControllers and inits it with the given trackView
 * @param aProxyObject VSTimelineObjectProxy the VSTimelineObjectViewController will be init with
 **/
-(VSTimelineObjectViewController*) addTemporaryTimelineObject:(VSTimelineObjectProxy*) aProxyObject;

/**
 * Adds a new VSTimelineObjectViewController to self.temporaryTimelineObjectViewControllers and inits it with the given trackView
 * @param aProxyObject VSTimelineObjectProxy the VSTimelineObjectViewController will be init with
 * @param doubleFrame VSDoubleFrame set as doubleFrame of VSTimelineObjectView representing the temporary timlineObject;
 **/
-(VSTimelineObjectViewController*) addTemporaryTimelineObject:(VSTimelineObjectProxy*) aProxyObject withDoubleFrame:(VSDoubleFrame) doubleFrame;

/**
 * Returns all currently selected TimelineObjects on the track
 * @return NSArray containing all VSTimelineObjectViewController with representing selected TimelineObjects
 */
-(NSArray*) selectedTimelineObjectViewControllers;

/**
 * Removes all VSTimelineObjectVies stored in self.temporaryTimelineObjectViewControllers from the trackView and clears self.temporaryTimelineObjectViewControllers.
 * @return YES if the resetting was successfully, NO otherweise
 */
-(BOOL) resetTemporaryTimelineObjects;

/**
 * Sets inactive-Property to YES for all views with selected TimelineObjects
 */
-(void) deactivateSelectedTimelineObjects;

/**
 * Removes the intersections of all timeline objects
 */
-(void) resetIntersections;

/**
 * Sets inactive-Property to NO for all views with selected TimelineObjects
 */
-(void) activateSelectedTimelineObjects;

/**
 * Copies the temporary stored timelineObjects onto the track thus they become timeline objects of the track
 */
-(void) copyTemporaryTimelineObjectsToTrack;

/**
 * Removes the currently selected TimelineObjects which are set inactive
 */
-(void) removeInactiveSelectedTimelineObjectViewControllers;

/**
 * Moveable TimelineObjects are all selected and all temporay TimlineObjects
 * @return All currently moveable TimelineObjects
 */
-(NSArray*) movableTimelineObjectViewControllers;

/**
 * Computes the nearest distance from the given position to the left or right end of all VSTimelineObjectViews on the track
 *
 * Forward indicates if for the nearest distance is looked for right or left from the given position.
 * @param position Position the distance is computed to
 * @param forward If YES for the nearest distance is looked for right from the given position.
 * @return The nearest distance if it's bigger than 0.01, zero otherweise
 */
-(float) distanceToNearestCutFromPosition:(float) position forward:(BOOL) forward;

@end
