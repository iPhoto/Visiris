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
@property (strong) AVPlayer *audioPlayer;


@end


@implementation VSAudioPlayer

@synthesize filePath    = _filePath;
@synthesize audioPlayer = _audioPlayer;


#pragma mark - Init

- (id)initWithFilePath:(NSString *)path{
    if (self = [super init]) {

        __autoreleasing NSError *error = nil;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];

        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];

        
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        if([asset tracksWithMediaType:AVMediaTypeAudio].count == 0){
            return nil;
        }
        
        
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,asset.duration)
                                       ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0]
                                        atTime:kCMTimeZero
                                         error:&error];
                
        self.audioPlayer = [[AVPlayer alloc] initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:composition]];
        
        
        
        if (error) {
            NSLog(@"ERROR im Audioerstellen");
            [NSApp presentError:error];
        }
    }
    return self;
}


#pragma mark - Methods

- (void)playAtTime:(double)time{
    //TODO soll nicht immer abgefragt werden....vielleicht nur einmal in der sekunde oder so (also die ganze funktion)
    if ( [self.audioPlayer rate] == 0.0) {
        [self.audioPlayer play];
    }
//    //TODO 0.05 is kind of magic        
    if (abs(time - CMTimeGetSeconds([self.audioPlayer currentTime])) > 0.05) {
        [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(time, 1)];
    }
}

- (void)stopPlaying{
    [self.audioPlayer pause];
//    NSLog(@"rate: %f", [self.audioPlayer rate]);
}

- (void)setVolume:(float)volume{
    
    if ([self.audioPlayer volume] != volume) {
        [self.audioPlayer setVolume:volume];
    }
}

- (void)completeStop{
    //TODO is this neccessary
//    NSLog(@"Audio complete Stop not working");
}

- (NSString *)description{
    NSString *string = [NSString stringWithFormat:@"Player.hash: %ld", self.hash];
    return string;
}

@end
