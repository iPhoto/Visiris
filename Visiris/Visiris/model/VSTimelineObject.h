//
//  VSTimelineObject.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTimelineObjectProxy.h"
#import "VisirisCore/VSPlaybackMode.h"

#import "VSCoreServices.h"

@class VSTimelineObjectSource;
@class VSSourceSupplier;
@class VSCoreHandover;
@class VSDevice;


/**
 * Representation of objects placed on the timeline.
 * 
 * A VSTimelineObject stores the ProjectItem that it's representing. Also the position and the duration of the object on the timeline are stored in the object
 */
@interface VSTimelineObject : VSTimelineObjectProxy<NSCopying, NSCoding>

/** Object the TimelineObject is representing */ 
@property (strong) VSTimelineObjectSource* sourceObject;

/** Supplier responsible for the this timelineObject */
@property (strong) VSSourceSupplier *supplier;

/** Duaration of the projectItem the timelineObject represents, the "real" length of file */
@property (readonly) double sourceDuration;

@property (readonly, strong) NSMutableArray* devices;

@property (weak,readonly) VSFileType *fileType;

@property (weak, readonly) NSString *filePath;

/**
 * Inits a the object with the given sourceObject
 * @param sourceObject SourceObject the timelineObject represents on the timeline
 * @param icon Thumbnail of the file
 * @param objectID Unique ID of the timelineObject
 */
-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon objectID:(NSInteger) objectID;

/**
 * Adds the startTime and the duration to get the timeposition where the object ends on the timeline
 * @return Timeposition of the end of the object.
 */
-(double) endTime;

/**
 * Tells the supplier to provide data for the given timestamp, so the VSTimelineObject can return the VSCorHandover for given timestamp and framesize.
 * @param aTimestamp Timstamp the VSCoreHandover is created for.
 * @param aFrameSize FrameSize the VSCoreHandover is setup for.
 * @param mode Current play mode as definend in VSPlaybackMode
 */
- (VSCoreHandover *)handoverForTimestamp:(double)aTimestamp frameSize:(NSSize)aFrameSize withPlayMode:(VSPlaybackMode)mode;

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

/**
 * Changes the name of VSTimelineObject and registers the change at the give undoManger
 * @param newName Name the VSTimelineObject's name will be changed to.
 * @param undoManager NSUndoManager the change of the selection is registrated at.
 */
-(void) changeName:(NSString*)newName andRegisterAt:(NSUndoManager*) undoManager;

/**
 * Converts the given globalTimestamp to one relative to the VSTimelineObject
 * @param aGlobalTimestamp Global timeStamp to be converted in relative one.
 * @return Returns the converted relative timestamp
 */
- (double)localTimestampOfGlobalTimestamp:(double)aGlobalTimestamp;

-(double) globalTimestampOfLocalTimestamp:(double)aLocalTimestamp;

-(void) addDevicesObject:(VSDevice *)object;

-(NSArray*) devicesAtIndexes:(NSIndexSet *)indexes;

-(VSDevice*) deviceIdentifiedBy:(NSString*) deviceID;

-(void) disconnectDevice:(VSDevice*) device;

-(void) removeDevice:(VSDevice*)device;

@end
