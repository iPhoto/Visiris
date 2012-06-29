//
//  VSFrameSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSourceSupplier.h"

@class VSImage;

/**
 * Supplier for frame based VSTimlelineObjects like Videos and imags. Subclassed of VSSourceSupplier. Adds a function to return a frame for a given timestamp to its parent class.
 */
@interface VSFrameSourceSupplier : VSSourceSupplier

@property (strong) VSImage *vsImage;


/**
 * Renders a frame for the content the timlineObject represents for the given timestamp in the given size.
 * @param aTimestamp Defines the frame that will be rendered. The timestamp has to be in local time of the timelineObject.
 * @param playing Indicates function is called during a running playback or for one frame only e.g. during scrubbing over the timeline.
 * @returns Pointer to the created frame.
 */
-(VSImage*) getFrameForTimestamp:(double) aTimestamp isPlaying:(BOOL)playing;

@end
