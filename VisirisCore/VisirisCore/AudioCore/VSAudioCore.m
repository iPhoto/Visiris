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

/** The  */
@property (strong) VSAudioPlayerManager     *audioPlayerManager;

@end


@implementation VSAudioCore
@synthesize audioPlayerManager = _audioPlayerManager;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.audioPlayerManager = [[VSAudioPlayerManager alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path{
    [self.audioPlayerManager createAudioPlayerForProjectItemID:projectItemID withObjectItemID:objectItemID atTrack:trackID andFilePath:path];
}

- (void)playAudioOfHandovers:(NSArray *)handovers atTimeStamp:(double)timeStamp{
        
    for (VSCoreHandover *coreHandover in handovers) {
        if ([coreHandover isKindOfClass:[VSAudioCoreHandover class]]){   
            
            float volume = [[coreHandover.attributes objectForKey:VSParameterAudioVolume] floatValue];
                        
            NSInteger objectID = coreHandover.timeLineObjectID;
            [self.audioPlayerManager playAudioOfObjectID:objectID atTime:coreHandover.timestamp/1000.0 atVolume:volume];
        }
    }
}

- (void)stopPlaying{
    [self.audioPlayerManager stopPlaying];
}

@end
