//
//  VSFrameSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSourceSupplier.h"
#import "VisirisCore/VSPlaybackMode.h"

@class VSImage;

/**
 * Supplier for frame based VSTimlelineObjects like Videos and imags. Subclassed of VSSourceSupplier. Adds a function to return a frame for a given timestamp to its parent class.
 */
@interface VSFrameSourceSupplier : VSSourceSupplier

/** VSImage is basically a struct which contains the needed Information of a Frame for creating a OpenglTexture in the Core  */
@property (strong) VSImage *vsImage;

/**
 * Renders a frame for the content the timlineObject represents for the given timestamp in the given size.
 * @param aTimestamp Defines the frame that will be rendered. The timestamp has to be in local time of the timelineObject.
 * @param playMode Current playbackMode as defined in VSPlaybackMode
 * @returns Pointer to the created frame.
 */
-(VSImage *) getFrameForTimestamp:(double)aTimestamp withPlayMode:(VSPlaybackMode)playMode;

@end
