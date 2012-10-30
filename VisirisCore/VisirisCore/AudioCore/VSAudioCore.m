//
//  VSAudioCore.m
//  VisirisCore
//
//  Created by Scrat on 18/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAudioCore.h"
#import "VSAudioPlayerManager.h"
#import "VSCoreHandover.h"
#import "VSAudioCoreHandover.h"
#import "VSParameterTypes.h"

@interface VSAudioCore()

/** Manages two dictionaries containing the audio information */
@property (strong) VSAudioPlayerManager     *audioPlayerManager;

@end


@implementation VSAudioCore
@synthesize audioPlayerManager = _audioPlayerManager;


#pragma mark - Init

- (id)init{
    if (self = [super init]) {
        self.audioPlayerManager = [[VSAudioPlayerManager alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path{
    [self.audioPlayerManager createAudioPlayerForProjectItemID:projectItemID withObjectItemID:objectItemID atTrack:trackID andFilePath:path];
//    NSLog(@"created");
}

- (void)playAudioOfHandovers:(NSArray *)handovers atTimeStamp:(double)timeStamp{
    for (VSCoreHandover *coreHandover in handovers) {
        float volume = [[coreHandover.attributes objectForKey:VSParameterAudioVolume] floatValue];
                    
        NSInteger objectID = coreHandover.timeLineObjectID;
        [self.audioPlayerManager playAudioOfObjectID:objectID atTime:coreHandover.timestamp atVolume:volume];
    }
}

- (void)stopPlaying{
//    NSLog(@"audioCore stop");
    [self.audioPlayerManager stopPlaying];
}

- (void)stopTimeLineObject:(NSInteger)timelineObjectID{
    [self.audioPlayerManager stopPlayingOfTimelineObject:timelineObjectID];
}

- (void)deleteTimelineobjectID:(NSInteger)timelineobjectID{
//    [self stopTimeLineObject:timelineobjectID];
    [self.audioPlayerManager deleteTimelineobjectID:timelineobjectID];
}

- (void)printDebugLog{
    [self.audioPlayerManager printDebugLog];
}

@end
