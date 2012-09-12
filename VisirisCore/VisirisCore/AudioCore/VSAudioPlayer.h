//
//  VSAudioPlayer.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Basic Class for handling Audiofiles
 */
@interface VSAudioPlayer : NSObject

/** Absolute filepath on the harddrive of the file */
@property (readonly, strong) NSString       *filePath;


/**
 * Basic Initialization using a Filepath
 * @param path Absolute filepath on the harddrive of the file
 */
- (id)initWithFilePath:(NSString *)path;

/**
 * Plays the Audiofile at a specific time
 * @param time Actual Timestamp
 */
- (void)playAtTime:(double)time;

/**
 * Stops the Playback
 */
- (void)stopPlaying;

/**
 * Sets the volume of the Audio
 * @param volume Range from 0 - 1
 */
- (void)setVolume:(float)volume;

/**
 * Real Stop, not just pause like stopPlaying
 */
- (void)completeStop;


@end
