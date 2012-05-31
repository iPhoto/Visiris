//
//  VSCoreHandover.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The VSCoreHandover is used to handover data from the UI/Model-Part of Visiris to the RenderCore. 
 *
 * The handover stores the parameter for an VSTimelineObject and additional information according to the type of the ProjectItem the timelineObject stores
 */
@interface VSCoreHandover : NSObject

//TODO: is the time stamp local or global?
@property double timestamp;

/** NSDictionary containing the parameters, the VSParemterType property of the VSParameter object is used as Key. */
@property NSDictionary *attributes;
 

#pragma mark - Init

/**
 * Inits the VSCoreHandover for the given timestmap with the given attributes
 * @param theAttributes NSDictionary containing the parameters, the VSParemterType property of the VSParameter object is used as Key.
 * @param The timestamp the data is set of
 */
-(id) initWithAttributes:(NSDictionary *) theAttributes forTimestamp:(double) theTimestamp;

@end