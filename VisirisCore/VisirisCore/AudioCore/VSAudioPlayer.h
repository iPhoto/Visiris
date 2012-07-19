//
//  VSAudioPlayer.h
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSAudioPlayer : NSObject

@property (readonly, strong) NSString       *filePath;

- (id)initWithFilePath:(NSString *)path;
- (void)playAtTime:(double)time;
- (void)stopPlaying;
- (void)setVolume:(float)volume;

@end
