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
@property (strong) NSMutableDictionary      *referenceCountingToPlayer;

@end


@implementation VSAudioPlayerManager

@synthesize playerCollectionToTrackID       = _playerCollectionToTrackID;
@synthesize playerToObjectID                = _playerToObjectID;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.playerCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.playerToObjectID = [[NSMutableDictionary alloc] init];
        self.referenceCountingToPlayer = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (void)createAudioPlayerForProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID atTrack:(NSInteger)trackID andFilePath:(NSString *)path{
    
//    NSLog(@"create objectID %ld", objectItemID);

    if (path) {
        NSMutableDictionary *trackPlayer = [self.playerCollectionToTrackID playerCollectionForTrackID:trackID];
        if (!trackPlayer) {
            
            trackPlayer = [NSMutableDictionary dictionary];
            [self.playerCollectionToTrackID setObject:trackPlayer forKey:[NSNumber numberWithInteger:trackID]];
            
            VSAudioPlayer *audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
            
            [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
            [self incrementReferenceCounting:audioPlayer];
        }
        else {
            
            VSAudioPlayer *audioPlayer = [trackPlayer objectForKey:[NSNumber numberWithInteger:projectItemID]];
            
            if (audioPlayer == nil) {
                audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
                [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];
            }
            
            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
            [self incrementReferenceCounting:audioPlayer];
        }
    }
    
//    [self printReferenceTable];
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
//    NSLog(@"delete objectID %ld", objectID);
//    NSLog(@"description: %@",((VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:objectID]]).description);
    VSAudioPlayer *temp = (VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:objectID]];
    
    [self decrementReferenceCounting:temp];
//    [self printReferenceTable];

}


#pragma mark - Private Methods

/**
 * Incrementing one specific Referencecounter
 * @param projectItemID The ID of the ProjectItem
 */
- (void)incrementReferenceCounting:(VSAudioPlayer *)player{
    
    NSNumber *current = (NSNumber *)[self.referenceCountingToPlayer objectForKey:[NSNumber numberWithInteger:player.hash]];
    int currentInt;
    
    if (current == nil)
        currentInt = 0;
    else
        currentInt = [current intValue];
    
    currentInt++;
    [self.referenceCountingToPlayer setObject:[NSNumber numberWithInt:currentInt]  forKey:[NSNumber numberWithInteger:player.hash]];
}

/**
 * Decrement one specific Referencecounter
 * @param player The reference counter needs the associating player
 */
- (void)decrementReferenceCounting:(VSAudioPlayer *)player{
    NSNumber *current = (NSNumber *)[self.referenceCountingToPlayer objectForKey:[NSNumber numberWithInteger:player.hash]];
    int currentInt;
    
    if (current == nil)
        NSLog(@"Decrementing somethings that not there");
    else
        currentInt = [current intValue];
    
    currentInt--;
    
    if (currentInt == 0) {
        //delete the reference
        [self.referenceCountingToPlayer removeObjectForKey:[NSNumber numberWithInteger:player.hash]];
        
        //delete all inside the trackcollection
        for (id track in self.playerCollectionToTrackID) {
            NSMutableDictionary *trackDictionary = (NSMutableDictionary *)[self.playerCollectionToTrackID objectForKey:track];
            
            for (id key in trackDictionary) {
                if (player == [trackDictionary objectForKey:key]) {
                    [trackDictionary removeObjectForKey:key];
                }
            }
        }
        [player completeStop];
    }
    else{
        [self.referenceCountingToPlayer setObject:[NSNumber numberWithInt:currentInt]  forKey:[NSNumber numberWithInteger:player.hash]];
    }
}

/**
 * A simple Printing Method for Debugging.
 */
- (void)printReferenceTable{
    NSLog(@"PrintingReferenceTable----------------------------------------------");
    for (id key in self.referenceCountingToPlayer) {
        NSLog(@"player: %@, value: %@", key, [self.referenceCountingToPlayer objectForKey:key]);
    }
}

@end
