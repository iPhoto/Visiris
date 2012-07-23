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

@property (strong) AVAudioPlayer *audioPlayer;

@end


@implementation VSAudioPlayer

@synthesize filePath    = _filePath;
@synthesize audioPlayer = _audioPlayer;

- (id)initWithFilePath:(NSString *)path{
    if (self = [super init]) {

        __autoreleasing NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:path] error:&error];
        if (error) {
            NSLog(@"ERROR im Audioerstellen");
            [NSApp presentError:error];
        }
        else {
            [self.audioPlayer prepareToPlay];
           // [self.audioPlayer play];
           // [self.audioPlayer pause];
        }
        
    }
    return self;
}

- (void)playAtTime:(double)time{
    if ([self.audioPlayer isPlaying] == NO) {
        [self.audioPlayer play];
    }
    
    if (abs((time - [self.audioPlayer currentTime])) > 0.05) {
        [self.audioPlayer setCurrentTime:time];
    }
    
//    NSLog(@"TimeStamp: %f",time);
//    NSLog(@"PlayerTime: %f",[self.audioPlayer currentTime]);
//    NSLog(@"audiolength: %f",[self.audioPlayer duration]);
//    NSLog(@"difference: %f",time/1000.0 - [self.audioPlayer currentTime]);
}

- (void)stopPlaying{
    [self.audioPlayer pause];
}

- (void)setVolume:(float)volume{
    if ([self.audioPlayer volume] != volume) {
        [self.audioPlayer setVolume:volume];
    }
}


@end
