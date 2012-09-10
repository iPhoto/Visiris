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

/** This Dictionary matches TrackID's to other Dictionaries which contains the VSAudioplayeritmes */
@property (strong) NSMutableDictionary      *playerCollectionToTrackID;

/** Matches an ObjectID to a VSAudioplayer */
@property (strong) NSMutableDictionary      *playerToObjectID;

/** Is for knowing how many Timelineobjects are referencing one AudioPlayer.*/
@property (strong) NSMutableDictionary      *referenceCountingToProjectItemID;

@end


@implementation VSAudioPlayerManager

@synthesize playerCollectionToTrackID       = _playerCollectionToTrackID;
@synthesize playerToObjectID                = _playerToObjectID;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.playerCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.playerToObjectID = [[NSMutableDictionary alloc] init];
        self.referenceCountingToProjectItemID = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path{
    
    if (path) {

        NSMutableDictionary *trackPlayer = [self.playerCollectionToTrackID playerCollectionForTrackID:trackID];
        if (!trackPlayer) {
            
            trackPlayer = [NSMutableDictionary dictionary];
            [self.playerCollectionToTrackID setObject:trackPlayer forKey:[NSNumber numberWithInteger:trackID]];
            
            VSAudioPlayer *audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
            
            [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
            
            [self incrementReferenceCounting:projectItemID];
        }
        else {
            
            VSAudioPlayer *audioPlayer = [trackPlayer objectForKey:[NSNumber numberWithInteger:projectItemID]];
            
            if (audioPlayer == nil) {
                audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
                [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

                [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
                [self incrementReferenceCounting:projectItemID];
            }
        }
    }
    
    [self printReferenceTable];
}

- (void)playAudioOfObjectID:(NSInteger)objectID atTime:(double)time atVolume:(float)volume{
    VSAudioPlayer *player = (VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:objectID]];
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

- (void)deleteTimelineobjectID:(NSInteger)objectID{
    NSLog(@"description: %@",((VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:objectID]]).description);
    
}


#pragma mark - Private Methods

/**
 * Incrementing one specific Referencecounter
 * @param projectItemID The ID of the ProjectItem
 */
- (void)incrementReferenceCounting:(NSInteger)projectItemID{
    
    NSNumber *current = (NSNumber *)[self.referenceCountingToProjectItemID objectForKey:[NSNumber numberWithInteger:projectItemID]];
    int currentInt;
    
    if (current == nil)
        currentInt = 0;
    else
        currentInt = [current intValue];
    
    currentInt++;
    [self.referenceCountingToProjectItemID setObject:[NSNumber numberWithInt:currentInt]  forKey:[NSNumber numberWithInteger:projectItemID]];
}

/**
 * A simple Printing Method for Debugging.
 */
- (void)printReferenceTable{
    NSLog(@"PrintingReferenceTable----------------------------------------------");
    for (id key in self.referenceCountingToProjectItemID) {
        NSLog(@"projectItemID: %@, value: %@", key, [self.referenceCountingToProjectItemID objectForKey:key]);
    }
    NSLog(@"--------------------------------------------------------------------");
}


@end
