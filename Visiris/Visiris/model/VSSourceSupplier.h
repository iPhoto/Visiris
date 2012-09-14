//
//  VSSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSTimelineObject;

/**
 * The Supplier is responsible for providing the parameter values ant the content of VSTimelinObject for an specific Timestamp.
 */
@interface VSSourceSupplier : NSObject

/** VSTimelineObject the Supplier is responsible for */
@property (weak, readonly) VSTimelineObject *timelineObject;

/**
 * Inits the VSSourceSupplier and sets the timelineObject-Property it is connected to
 * @param aTimelineObject VSTimelineObject the VSSourceSupplier is connected to
 * @return self;
 */
-(id) initWithTimelineObject:(VSTimelineObject*) aTimelineObject;

/**
 * The supplier creates an NSDictionary containing the values of its VSTimelineObject's parameters at the given timestamp.
 * @param aTimestamp Timestamp the values of the VSTimelineObject are generated for. The timestamp has to be in local time of the timelineObject.
 * @return NSDictionary containing the values of the supplier's VSTimelineObject's parameters at the given timestamp. The type - Property of VSParameter is used as Key.
 */
- (NSDictionary *)getAtrributesForTimestamp:(double) aTimestamp;

@end
