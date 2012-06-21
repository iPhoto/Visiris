//
//  VSPlayHead.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Represents the playhead of timeline and holds the timestamp of the current frame
 */
@interface VSPlayHead : NSObject

/** Current Position of the playhead on the timeline in milliseconds */
@property double currentTimePosition;

/** Indicates wheter the playhead is moved ("scrubbed") by the user on the UI, or moved automatically during a playback. */
@property BOOL scrubbing;

@end
