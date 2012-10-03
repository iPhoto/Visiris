//
//  VSAudioSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSSourceSupplier.h"

@interface VSAudioSourceSupplier : VSSourceSupplier

/**
 * Converts the localTimestamp to the audioTimeStamp (handles Looping)
 * @param localTimestamp localtimestamp of the Timelineobject
 * @return the newTimestamp
 */
- (double)convertToAudioTimestamp:(double)localTimestamp;

@end
