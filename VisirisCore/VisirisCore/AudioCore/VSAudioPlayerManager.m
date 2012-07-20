//
//  VSAudioPlayerManager.m
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAudioPlayerManager.h"
#import "NSMutableDictionary+VSAudioPlayerManger.h"
#import "VSAudioPlayer.h"

@interface VSAudioPlayerManager()

@property (strong) NSMutableDictionary      *playerCollectionToTrackID;
@property (strong) NSMutableDictionary      *playerToObjectID;

@end


////////////////////////////////////////

@implementation VSAudioPlayerManager

@synthesize playerCollectionToTrackID       = _playerCollectionToTrackID;
@synthesize playerToObjectID                = _playerToObjectID;

- (id)init{
    if (self = [super init]) {
        self.playerCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.playerToObjectID = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path{
    
    if (path) {

        NSMutableDictionary *trackPlayer = [self.playerCollectionToTrackID playerCollectionForTrackID:trackID];
        if (!trackPlayer) {
            
            trackPlayer = [NSMutableDictionary dictionary];
            [self.playerCollectionToTrackID setObject:trackPlayer forKey:[NSNumber numberWithInteger:trackID]];
            
            VSAudioPlayer *audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
            
            [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInt:objectItemID]];            
        }
        else {
            
            VSAudioPlayer *audioPlayer = [trackPlayer objectForKey:[NSNumber numberWithInteger:projectItemID]];
            
            if (audioPlayer == nil) {
                audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
                [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

                [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInt:objectItemID]];
            }
        }
    }
}

- (void)playAudioOfObjectID:(NSInteger)objectID atTime:(double)time atVolume:(float)volume{
    VSAudioPlayer *player = (VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInt:objectID]];
    if (player == nil) {
        NSLog(@"shit happens");
    }
    [player playAtTime:time];
    [player setVolume:volume]; 
}

- (void)stopPlaying{
    
    NSArray* keys = [self.playerToObjectID allKeys];
    for(NSString* key in keys) {
        VSAudioPlayer *player = (VSAudioPlayer *)[self.playerToObjectID objectForKey:key];
        [player stopPlaying];
    }
}




@end