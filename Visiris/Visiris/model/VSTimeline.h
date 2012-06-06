//
//  VSTimeline.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTrack.h"

@class VSTrack;
@class VSProjectItemRepresentation;
@class VSTimelineObjectFactory;
@class VSTimelineObjectProxy;

/**
 * Protocoll to inform about changes of the VSTimelineObjects of VSTrack's the VSTimeline is responsible for
 */
@protocol VSTimelineTimelineObjectsDelegate <NSObject>

@required

/**
 * Called when timelineObjects have been added a track.
 * @param newTimelineObjects NSArray storing the newly added VSTimelineObjects.
 * @param aTrack VSTrack the timelineObjects have been added to
 */
-(void) timelineObjects:(NSArray*) newTimelineObjects haveBeenAddedToTrack:(VSTrack*) aTrack;

/**
 * Called before timelineObjects have been removed from a track.
 * @param removedTimelineObjects NSArray storing the VSTimelineObjects they will removed.
 * @param aTrack VSTrack the timelineObjects will be removed from
 */
-(void) timelineObjects:(NSArray*) removedTimelineObjects willBeRemovedFromTrack:(VSTrack*) aTrack;

@end


/**
 * Timeline Model Object
 *
 * Represents the Timeline of Visiris. Stores a several number of tracks where new TimelinObjects can be added. 
 */
@interface VSTimeline : NSObject

#pragma mark - Properties

/** Stores the tracks of the timeline */
@property (strong) NSMutableArray *tracks;

/** Duration of the timeline */
@property double duration;

/** Delegate that is informed as definied in the VSTimelineTimelineObjectsDelegate protocoll */
@property id<VSTimelineTimelineObjectsDelegate> timelineObjectsDelegate;

#pragma mark - Init

/**
 * Inits a new timeline with the given duration.
 * @param duration Duration the timeline will be init with.
 */
-(id) initWithDuration:(float) duration;

/**
 * Adds a new track to the timeline and inits it with the given values
 * @param name Name of the new Track
 * @param type Indicates wheter the track is an Audio- or an Visual-Track
 * @return YES if the track was added successfully, NO otherwise.
 */
-(BOOL) addNewTrackNamed:(NSString*) name ofType:(VSTrackType) type;


#pragma mark - Methods

/**
 * Adds a new Timeline-Object to the given track.
 *
 * A new timeline object is created by the VSTimelineObjectFactory according to the given VSProjectItem.
 * @param item VSTimelineObjectRepresentation the new TimelineObject is connected with
 * @param track Track the TimelineObject will be added to.
 * @param timePosition Start-time of the timelineObject.
 * @param duration Duration of the VSTimelineObject
 * @return YES if the timeline object was create successfully, NO otherwise.
 */
-(VSTimelineObject*) addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *) item toTrack :(VSTrack *)track positionedAtTime:(double) timePosition withDuration:(double) duration;

/**
 * Adds a new Timeline-Object to the given track and registers the adding at the given NSUndoManger
 *
 * A new timeline object is created by the VSTimelineObjectFactory according to the given VSProjectItem.
 * @param item VSTimelineObjectRepresentation the new TimelineObject is connected with
 * @param track Track the TimelineObject will be added to.
 * @param timePosition Start-time of the timelineObject.
 * @param duration Duration of the VSTimelineObject
 * @param undoManager NSUndoManeger the adding of the TimelineObject is registrated at.
 * @return YES if the timeline object was create successfully, NO otherwise.
 */
-(VSTimelineObject*) addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *) item toTrack :(VSTrack *)track positionedAtTime:(double) timePosition withDuration:(double) duration andRegisterUndoOperation:(NSUndoManager*) undoManager;



/**
 * Removes aTimelineObject from the track and returns if the removal was successful.
 * @param aTimelineObject VSTimelineObject to be removed
 * @param track VSTrack aTimelineObject is placed on
 * @return YES if the removal was successfully, NO otherwise
 */
-(BOOL) removeTimelineObject:(VSTimelineObject*) aTimelineObject fromTrack:(VSTrack*) track;

/**
 * Removes all currently selected VSTimelineObjects from the Timeline and registers the operation at the given NSUndoManager
 @param undoManager NSUndoManager the removal is registrated at.
 */
-(void) removeSelectedTimelineObjectsAndRegisterAtUndoManager:(NSUndoManager*) undoManager;



/**
 * Creates a new TimelineObjectProxy.
 *
 * A new TimelineObjectProxy object is created according to the given VSProjectItemRepresentation object and returned
 * @param item VSTimelineObjectRepresentation the new TimelineObject is connected with
 * @param timePosition Start-time of the timelineObject.
 * @return The TimelineObjectProxy if it was created succesfully, nil otherwise.
 */
-(VSTimelineObjectProxy*) createNewTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *) item positionedAtTime:(double) timePosition;

/**
 * Asks its tracks for all timelineObjects which are active at the given timestamp.
 * @param aTimestamp Timestamp, the active timelineObjects are looked up for.
 * @return Array of the timelineObjects acitve at the given timestamp
 */
- (NSArray *)timelineObjectsForTimestamp:(double)aTimestamp;

/**
 * Sets selected of the given VStimelinObject to YES.
 * @param timelineObjectToSelect VSTimelineObject that will be selected
 * @param aTrack VSTrack the timelineObjectToSelect is placed on
 */
-(void) selectTimelineObject:(VSTimelineObject*) timelineObjectToSelect onTrack:(VSTrack*) aTrack;

/**
 * Sets selected of the given VStimelinObject to NO.
 * @param timelineObjectToUnselect VSTimelineObject that will be unselected
 * @param aTrack VSTrack the timelineObjectToUnselect is placed on
 */
-(void) unselectTimelineObject:(VSTimelineObject*) timelineObjectToUnselect onTrack:(VSTrack*) aTrack;

/**
 * Sets selected of all VSTimelineObjects stored in the VSTracks of the timeline to NO
 */
-(void) unselectAllTimelineObjects;

/**
 * Collects all selected VSTimelineObjects of the tracks the timeline is responsible for
 * @return NSArray of all currently selected VSTimelineObjects
 */
-(NSArray*) selectedTimelineObjects;

@end
