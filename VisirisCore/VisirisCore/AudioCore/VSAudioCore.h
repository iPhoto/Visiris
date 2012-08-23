//
//  VSAudioCore.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * The AudioCore is for handling the Audio.
 */
@interface VSAudioCore : NSObject

/**
 * Is for creating a Audioplayer as soon a Timelineobject with Audio gets dropped on a track.
 * @param projectItemID Each Timelineobject is referencing one projectItemID. Timelineobject : projectItem = n:1
 * @param objectItemID TimelineObjectID
 * @param trackID Number/Line of the Track
 * @param path The absolute Path on the harddrive
 */
- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path;

/**
 * Gets called at runtime. Is for controlling the current playing audio
 * @param handovers Array containing the Audiohandovers
 * @param timeStamp Actual time
 */
- (void)playAudioOfHandovers:(NSArray *)handovers atTimeStamp:(double)timeStamp;

/**
 * Global Audioplaybackstop
 */
- (void)stopPlaying;

@end
