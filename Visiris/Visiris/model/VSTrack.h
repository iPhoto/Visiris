//
//  VSTrack.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSCoreServices.h"

@class VSTimelineObject;

/**
 * Model representation of a track on the timeline.
 *
 * A track manages the TimelineObjects placed on it.
 */
@interface VSTrack : NSObject<NSCoding>

/** Array of all TimelineObjects placed on the timeline */
@property (strong, readonly) NSMutableArray* timelineObjects;

/** Name of the track */
@property (strong) NSString* name;

/** Indicates if the Track is an audio- or an Visual-Track */
@property VSTrackType type;

/** id of the track */
@property NSUInteger trackID;

/**
 * Inits a new Track with the given values.
 * @param name Name of the track
 * @param trackID Unique ID of the track
 * @param type Indicates if the Track is an audio- or an Visual-Track 
 */
-(id) initWithName:(NSString*) name trackID:(NSInteger) trackID type:(VSTrackType) type;

/**
 * Adds the given TimelineObject to the track.
 * @param timelineObject Object to add.
 * @return YES if the object was added successfully to the track, NO otherwise
 */
-(BOOL) addTimelineObject:(VSTimelineObject*)timelineObject;

/**
 * Adds the given TimelineObject to the track and registers the operation at the given undoManager
 * @param timelineObject Object to add.
 * @param undoManager NSUndoManger the adding of the timelineObject is registrated
 * @return YES if the object was added successfully to the track, NO otherwise
 */
-(BOOL) addTimelineObject:(VSTimelineObject*)timelineObject andRegisterAtUndoManager:(NSUndoManager*) undoManager;

/**
 * Removes the timeline object from the track.
 * @param aTimelineObject VSTimelineObject that will be removed form the track.
 * @return YES if aTimelineObject was removed successfully, NO otherwise
 */
-(BOOL) removeTimelineObject:(VSTimelineObject*) aTimelineObject;

/**
 * Removes all selected TimelineObecjts from the track and registers the operation at the given undoManager
 * @param undoManager NSUndoManger the removal of the timelineObject is registrated
 */
-(void) removeSelectedTimelineObjectsAndRegisterAtUndoManager:(NSUndoManager*) undoManager;


/**
 * Removes the timeline object from the track and registers the operation at the given undoManager
 * @param aTimelineObject VSTimelineObject that will be removed form the track.
 * @param undoManager NSUndoManger the removal of the timelineObject is registrated
 * @return YES if aTimelineObject was removed successfully, NO otherwise
 */
-(BOOL) removeTimelineObject:(VSTimelineObject*) aTimelineObject andRegisterAtUndoManager:(NSUndoManager*) undoManager;

/**
 * Sets the selected property of the given VSTimelineObject to YES.
 * @param timelineObjectToSelect VSTimelineObject to be selected.
 */
-(void) selectTimelineObject:(VSTimelineObject*) timelineObjectToSelect;

/**
 * Sets the selected property of the given VSTimelineObject to NO.
 * @param timelineObjectToUnselect VSTimelineObject to be unselected.
 */
-(void) unselectTimelineObject:(VSTimelineObject*) timelineObjectToUnselect;

/**
 * Sets the selected property of VSTimelineObjects the VSTrack is responsible for to NO
 */
-(void) unselectAllTimelineObjects;

/**
 * Creates an Array of all VSTimelineObjects of the track where selected is YES
 * @return NSArray of the selected VSTimelineObjects of the track.
 */
-(NSArray*) selectedTimelineObjects;

/**
 * Goes through its VSTimelineObject stored in the timelineObjects-Property and returns thoes where the aTimestamp ist between the startTime and the endTime of the VSTimelineObject
 * @param aTimestamp VSTimelineObjects active at the given timestamp are returned
 * @return The VSTimelineObject where the given timestamp is between its startTime and endTime, nil if no VSTimelineObject was found.
 */
-(VSTimelineObject*) timelineObjectAtTimestamp:(double) aTimestamp; 

@end
