//
//  VSAudioPlayer.m
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAudioPlayer.h"
#import "AVFoundation/AVFoundation.h"

@interface VSAudioPlayer()

/** The AudioPlayer is provided by the AVFoundation framework and is for playing audio */
@property (strong) AVAudioPlayer *audioPlayer;

@end


@implementation VSAudioPlayer

@synthesize filePath    = _filePath;
@synthesize audioPlayer = _audioPlayer;


#pragma Mark - Init

- (id)initWithFilePath:(NSString *)path{
    if (self = [super init]) {

        __autoreleasing NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:path] error:&error];
        if (error) {
            NSLog(@"ERROR im Audioerstellen");
            [NSApp presentError:error];
        }
        else 
            [self.audioPlayer prepareToPlay];
    }
    return self;
}


#pragma mark - Methods

- (void)playAtTime:(double)time{
    if ([self.audioPlayer isPlaying] == NO) {
        [self.audioPlayer play];
    }
    
    //TODO 0.05 is kind of magic
    if (abs((time - [self.audioPlayer currentTime])) > 0.05) {
        [self.audioPlayer setCurrentTime:time];
    }
}

- (void)stopPlaying{
    [self.audioPlayer pause];
}

- (void)setVolume:(float)volume{
    if ([self.audioPlayer volume] != volume) {
        [self.audioPlayer setVolume:volume];
    }
}

- (void)completeStop{
    [self.audioPlayer stop];
}

@end
