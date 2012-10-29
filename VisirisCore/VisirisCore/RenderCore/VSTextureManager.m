//
//  VSTextureManager.m
//  VisirisCore
//
//  Created by Scrat on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTextureManager.h"
#import "VSTexture.h"
#import "VSReferenceCounting.h"
#import <OpenGL/glu.h>

@interface VSTextureManager()

/** This Dictionary matches TrackID's to textureToObjectID-Dictionaries */
@property (strong) NSMutableDictionary *textureCollectionToTrackID;

/** Matches an ObjectID to a VSTextureID */
@property (strong) NSMutableDictionary *textureToObjectID;

/** Is for knowing how many Timelineobjects are referencing one Texture */
@property (strong) VSReferenceCounting *referenceCountingGLTextureID;

@end


@implementation VSTextureManager

@synthesize textureCollectionToTrackID = _textureCollectionToTrackID;
@synthesize textureToObjectID = _textureToObjectID;


#pragma mark - Init

-(id)init{
    if (self = [super init]) {
        self.textureCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.textureToObjectID = [[NSMutableDictionary alloc] init];
        self.referenceCountingGLTextureID = [[VSReferenceCounting alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createTextureWithSize:(NSSize)size trackId:(NSInteger)trackId withObjectItemID:(NSInteger)objectItemID{
    
    NSMutableDictionary *trackTextures = [self.textureCollectionToTrackID objectForKey:[NSNumber numberWithInteger:trackId]];

    if (!trackTextures) {
        
        trackTextures = [NSMutableDictionary dictionary];
        [self.textureCollectionToTrackID setObject:trackTextures forKey:[NSNumber numberWithInteger:trackId]];
        
        VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size trackId:trackId];
        [trackTextures setObject:tempTexture forKey:[NSNumber numberWithInteger:((int)(size.width)*10000 + (int)size.height)]];
        [self.textureToObjectID setObject:tempTexture forKey:[NSNumber numberWithInteger:objectItemID]];
        [self incrementTextureReferenceCounting:tempTexture];

    }
    else {
        
        VSTexture *tempTexture = [trackTextures objectForKey:[NSNumber numberWithInteger:((int)(size.width)*10000 + (int)size.height)]];

        if (tempTexture == nil) {
            
            tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size trackId:trackId];
            [trackTextures setObject:tempTexture forKey:[NSNumber numberWithInteger:((int)(size.width)*10000 + (int)size.height)]];
        }
        
        [self.textureToObjectID setObject:tempTexture forKey:[NSNumber numberWithInteger:objectItemID]];
        [self incrementTextureReferenceCounting:tempTexture];

    }
}

- (VSTexture *)getVSTextureForTimelineobjectID:(NSInteger)timelineobjectID{
    
    VSTexture *texture = (VSTexture *)[self.textureToObjectID objectForKey:[NSNumber numberWithInteger:timelineobjectID]];
        
    if (texture == nil) {
        NSLog(@"createTextureWithSize texture is nil");
    }
    return texture;
}

- (void)deleteTextureForTimelineobjectID:(NSInteger)theID{
    VSTexture *texture = [self getVSTextureForTimelineobjectID:theID];
    
    if (texture) {
        [self decrementTextureReferenceCounting:texture];
        [self.textureToObjectID removeObjectForKey:[NSNumber numberWithInteger:theID]];
    }
}

- (NSInteger)trackIDfromObjectID:(NSInteger)objectID{
    
    VSTexture *tempTexture = (VSTexture *)[self.textureToObjectID objectForKey:[NSNumber numberWithInteger:objectID]];
    
    return tempTexture.trackId;
}

- (void)printDebugLog{
    NSLog(@"++++++++++++++++++++++++++DEBUG LOG TEXTURE-MANAGER++++++++++++++++++++++++++");
   
    NSLog(@"-----textureCollectionToTrackID-----");
    for (id trackID in self.textureCollectionToTrackID) {
        NSLog(@"trackID: %@, NSDictionary: %@", trackID, [self.textureCollectionToTrackID objectForKey:trackID]);
    }
    
    NSLog(@"-----textureToObjectID-----");
    for (id objectID in self.textureToObjectID) {
        NSLog(@"objectID: %@, VSTexture: %@", objectID, [self.textureToObjectID objectForKey:objectID]);
    }
    
    NSLog(@"-----referenceCountingGLTextureID-----");
    [self.referenceCountingGLTextureID printDebugLog];
}


#pragma mark - Private Methods

/**
 * Incrementing one specific Referencecounter
 * @param texture The reference counter needs the associating VSTexture
 */
- (void)incrementTextureReferenceCounting:(VSTexture *)texture{
    [self.referenceCountingGLTextureID incrementReferenceOfKey:[NSNumber numberWithInt:texture.texture]];
}

/**
 * Decrement one specific Referencecounter
 * @param texture The reference counter needs the associating VSTexture
 */
- (void)decrementTextureReferenceCounting:(VSTexture *)texture{
    
    if ([self.referenceCountingGLTextureID decrementReferenceOfKey:[NSNumber numberWithInt:texture.texture]] == NO) {

        id trackToDelete = nil;

        for (id track in self.textureCollectionToTrackID) {
            NSMutableDictionary *trackDictionary = (NSMutableDictionary *)[self.textureCollectionToTrackID objectForKey:track];
            
            id key = [NSNumber numberWithInteger:((int)(texture.size.width)*10000 + (int)texture.size.height)];
            VSTexture *tempTexture = [trackDictionary objectForKey:key];
            
            if (tempTexture) {
                [trackDictionary removeObjectForKey:key];
            }
            
            if(trackDictionary.count == 0){
                trackToDelete = track;
            }
        }
        
        if (trackToDelete) {
            [self.textureCollectionToTrackID removeObjectForKey:trackToDelete];
        }
        
        //finally delete the real texture on the GL Side
        [texture deleteTexture];
    }
}

@end
