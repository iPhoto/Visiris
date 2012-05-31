//
//  VSTimelineObject.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTimelineObjectProxy.h"

@class VSTimelineObjectSource;
@class VSSourceSupplier;
@class VSCoreHandover;

/**
 * Representation of objects placed on the timeline.
 * 
 * A VSTimelineObject stores the ProjectItem that it's representing. Also the position and the duration of the object on the timeline are stored in the object
 */
@interface VSTimelineObject : VSTimelineObjectProxy

/** Object the TimelineObject is representing */ 
@property (strong) VSTimelineObjectSource* sourceObject;

/** Supplier responsible for the this timelineObject */
@property (strong) VSSourceSupplier *supplier;


/**
 * Inits a the object with the given sourceObject
 * @param sourceObject SourceObject the timelineObject represents on the timeline
 * @param icon Thumbnail of the file
 * @param startTime Timeposition of the Object on the timeline 
 */
-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon;

/**
 * Adds the startTime and the duration to get the timeposition where the object ends on the timeline
 * @return Timeposition of the end of the object.
 */
-(double) endTime;

/**
 * Tells the supplier to provide data for the given timestamp, so the VSTimelineObject can return the VSCorHandover for given timestamp and framesize.
 * @param aTimestamp Timstamp the VSCoreHandover is created for.
 * @param aF3rameSize FrameSize the VSCoreHandover is setup for.
 */
- (VSCoreHandover *)handoverForTimestamp:(double)aTimestamp frameSize:(NSSize) aFrameSize;

/**
 * Returns the parameters of the VSTimelineObject as stored in its source.
 * @return The parameters of the VSTimelineObject as stored in its source where the type of the parameter is used as key
 */
- (NSDictionary *) parameters;

/**
 * Returns the parameters of the VSTimelineObject as stored in its source having hidden set to NO.
 * @return The parameters of the VSTimelineObject as stored in its source having hidden set to NO. The type of the parameter is used as key
 */
-(NSArray *) visibleParameters;

-(void) setSelectedAndRegisterUndo:(NSUndoManager*) undoManager;

-(void) setUnselectedAndRegisterUndo:(NSUndoManager*) undoManager;

-(void) changeName:(NSString*)newName andRegisterAt:(NSUndoManager*) undoManager;

@end
