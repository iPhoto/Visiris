//
//  VSAudioPlayerManager.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Manages the individual AudioPlayer
 */
@interface VSAudioPlayerManager : NSObject

/**
 * This is the same as in the AudioCore. Just chaining it through. Is for creating a Audioplayer as soon a Timelineobject with Audio gets dropped on a track. 
 * @param projectItemID Each Timelineobject is referencing one projectItemID. Timelineobject : projectItem = n:1
 * @param objectItemID TimelineObjectID
 * @param trackID Number/Line of the Track
 * @param path The absolute Path on the harddrive
 */

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path;

/**
 * Plays the audio of the Timelineobject.
 * @param objectID TimelineObjectID
 * @param time Actual Timestamp
 * @param volume AudioVolume from 0 to 1
 */
- (void)playAudioOfObjectID:(NSInteger)objectID atTime:(double)time atVolume:(float)volume;

/**
 * Global Audioplaybackstop
 */
- (void)stopPlaying;

/**
 * Stops the Playback of a TimelineObject
 * @param timelineObjectID The ID of the TimelineObject
 */
- (void)stopPlayingOfTimelineObject:(NSInteger)timelineObjectID;

/**
 * Gets called when a TimelineobjectID is removed in the gui
 * @param objectID The ID of the timelineobject
 */
- (void)deleteTimelineobjectID:(NSInteger)objectID;

/**
 * Prints everything that hold Objects
 */
- (void)printDebugLog;

@end
