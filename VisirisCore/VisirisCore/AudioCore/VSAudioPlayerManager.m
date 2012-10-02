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
#import "VSReferenceCounting.h"

@interface VSAudioPlayerManager()

/** This Dictionary matches TrackID's to other Dictionaries which contains the VSAudioplayeritmes */
@property (strong) NSMutableDictionary      *playerCollectionToTrackID;

/** Matches an ObjectID to a VSAudioplayer */
@property (strong) NSMutableDictionary      *playerToObjectID;

/** Is for knowing how many Timelineobjects are referencing one AudioPlayer.*/
@property (strong) VSReferenceCounting      *referenceCountingPlayer;

@end


@implementation VSAudioPlayerManager

@synthesize playerCollectionToTrackID       = _playerCollectionToTrackID;
@synthesize playerToObjectID                = _playerToObjectID;
@synthesize referenceCountingPlayer         = _referenceCountingPlayer;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.playerCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.playerToObjectID = [[NSMutableDictionary alloc] init];
        self.referenceCountingPlayer = [[VSReferenceCounting alloc] init];
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
            if (audioPlayer == nil) {
                NSLog(@"ERROR creating audioplayer");
                return;
            }
            
            [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];

            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
            [self incrementReferenceCountingOfPlayer:audioPlayer];
        }
        else {
            
            VSAudioPlayer *audioPlayer = [trackPlayer objectForKey:[NSNumber numberWithInteger:projectItemID]];
            
            if (audioPlayer == nil) {

                audioPlayer = [[VSAudioPlayer alloc] initWithFilePath:path];
                
                if (audioPlayer == nil) {
                    return;
                }

                [trackPlayer setObject:audioPlayer forKey:[NSNumber numberWithInteger:projectItemID]];
            }
            
            [self.playerToObjectID setObject:audioPlayer forKey:[NSNumber numberWithInteger:objectItemID]];
            [self incrementReferenceCountingOfPlayer:audioPlayer];
        }
    }
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

- (void)stopPlayingOfTimelineObject:(NSInteger)timelineObjectID{
    VSAudioPlayer *player = (VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:timelineObjectID]];
    
    if (player) {
        [player stopPlaying];
    }
    else
        NSLog(@"ERROR cannont stop a nil thingy");
}

- (void)deleteTimelineobjectID:(NSInteger)objectID{
//    NSLog(@"delete objectID %ld", objectID);
    VSAudioPlayer *temp = (VSAudioPlayer *)[self.playerToObjectID objectForKey:[NSNumber numberWithInteger:objectID]];
    
    if (temp) {
        [self decrementReferenceCountingOfPlayer:temp];
        [self.playerToObjectID removeObjectForKey:[NSNumber numberWithInteger:objectID]];
    }
}

- (void)printDebugLog{
    NSLog(@"++++++++++++++++++++++++++DEBUG LOG AUDIOCORE++++++++++++++++++++++++++");
    NSLog(@"-----playerCollectionToTrackID-----");
    for (id key in self.playerCollectionToTrackID) {
        NSLog(@"trackID: %@, playerCollection: %@", key, [self.playerCollectionToTrackID objectForKey:key]);
    }
    
    NSLog(@"-----playerToObjectID-----");
    for (id key in self.playerToObjectID) {
        NSLog(@"id: %@, value: %@", key, [self.playerToObjectID objectForKey:key]);
    }
    
    [self.referenceCountingPlayer printDebugLog];
}


#pragma mark - Private Methods

/**
 * Incrementing one specific Referencecounter
 * @param projectItemID The ID of the ProjectItem
 */
- (void)incrementReferenceCountingOfPlayer:(VSAudioPlayer *)player{
    [self.referenceCountingPlayer incrementReferenceOfKey:[NSNumber numberWithInteger:player.hash]];
}

/**
 * Decrement one specific Referencecounter
 * @param player The reference counter needs the associating player
 */
- (void)decrementReferenceCountingOfPlayer:(VSAudioPlayer *)player{
    
    if([self.referenceCountingPlayer decrementReferenceOfKey:[NSNumber numberWithInteger:player.hash]] == NO){
        
        id trackToDelete = nil;
        
        for (id track in self.playerCollectionToTrackID) {
            NSMutableDictionary *trackDictionary = (NSMutableDictionary *)[self.playerCollectionToTrackID objectForKey:track];
            
            for (id key in trackDictionary) {
                
                if (player == [trackDictionary objectForKey:key]) {
                    [trackDictionary removeObjectForKey:key];
                }
            }
    
            if(trackDictionary.count == 0){
                trackToDelete = track;
            }
        }

        if(trackToDelete){
            [self.playerCollectionToTrackID removeObjectForKey:trackToDelete];
        }
    }
}

@end
