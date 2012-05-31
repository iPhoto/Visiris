//
//  VSFrameSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSourceSupplier.h"

@interface VSFrameSourceSupplier : VSSourceSupplier

/**
 * Renders a frame for the content the timlineObject represents for the given timestamp in the given size.
 * @param aTimestamp Defines the frame that will be rendered. The timestamp has to be in local time of the timelineObject.
 * @param aFrameSize Size the frame will be created for.
 * @returns Pointer to the created frame.
 */
-(NSImage*) getFrameForTimestamp:(double) aTimestamp;

@end
