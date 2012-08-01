//
//  VSTimelineObjectProxy.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 14.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Representation of a VSTimelineObject. 
 *
 * !!!!!Please add more here !!!!!
 */
@interface VSTimelineObjectProxy : NSObject<NSCopying>

/** Timeposition of the Object on the timeline */
@property double startTime;

/** Duration of the object on the timeline */
@property double duration;

/** Name of the object, by defualt the same name as it's sourceObject */
@property (strong) NSString* name;

/** Thumbnail of the file */
@property (strong) NSImage* icon;

/** Indicates if object is selected or not */
@property BOOL selected;

/** unique ID of the timelineObject */
@property NSUInteger timelineObjectID;


@property (readonly) NSString *startTimeString;

#pragma mark- Init

/**
 * Creates VSTimelineObjectProxy and inits it with the given parameters
 * @param name Name of VSTimelineObject the VSTimelineObjectProxy represents.
 * @param startTime Time position on the timeline of VSTimelineObject the VSTimelineObjectProxy represents.
 * @param duration Duration of the VSTimelineObject the VSTimelineObjectProxy represents
 * @param icon of the VSTimelineObject the VSTimelineObjectProxy represents
 * @return self
 */
-(id) initWithName:(NSString*) name atTime:(double) startTime duration:(double) duration icon:(NSImage*) icon;

#pragma mark - Methods

/**
 * Changes the time position of the VSTimelineObjectProxy and registrats the change at the give NSUndoManager
 * @param startTime New time position the VSTimelineObjectProxy has been moved to
 * @param undoManager NSUndoManager the change of the start position is registrated at
 */
-(void) changeStartTime:(double)startTime andRegisterAtUndoManager:(NSUndoManager *)undoManager;

/**
 * Changes the duration of the VSTimelineObjectProxy and registrats the change at the give NSUndoManager
 * @param duration New duration of the VSTimelineObjectProxy 
 * @param undoManager NSUndoManager the change of the duration is registrated at
 */
-(void) changeDuration:(double)duration andRegisterAtUndoManager:(NSUndoManager *)undoManager;

/**
 * Sets the VSTimelineObject as selected and registers the state-change at the give undoManger
 * @param undoManager NSUndoManager the change of the selection is registrated at.
 */
-(void) setSelectedAndRegisterUndo:(NSUndoManager*) undoManager;


/**
 * Sets the VSTimelineObject as unselected and registers the state-change at the give undoManger
 * @param undoManager NSUndoManager the change of the selection is registrated at.
 */
-(void) setUnselectedAndRegisterUndo:(NSUndoManager*) undoManager;


@end
