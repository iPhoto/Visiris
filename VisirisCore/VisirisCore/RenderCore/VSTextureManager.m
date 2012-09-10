//
//  VSTextureManager.m
//  VisirisCore
//
//  Created by Scrat on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTextureManager.h"
#import "VSTexture.h"
#import <OpenGL/glu.h>

@interface VSTextureManager()

/** This Dictionary matches TrackID's to textureToObjectID-Dictionaries */
@property (strong) NSMutableDictionary *textureCollectionToTrackID;

/** Matches an ObjectID to a VSTextureID */
@property (strong) NSMutableDictionary *textureToObjectID;

/** Is for knowing how many Timelineobjects are referencing one Texture */
@property (strong) NSMutableDictionary *referenceCountingToGLTextureID;

@end


@implementation VSTextureManager

@synthesize textureCollectionToTrackID = _textureCollectionToTrackID;
@synthesize textureToObjectID = _textureToObjectID;


#pragma Mark - Init

-(id)init{
    if (self = [super init]) {
        self.textureCollectionToTrackID = [[NSMutableDictionary alloc] init];
        self.textureToObjectID = [[NSMutableDictionary alloc] init];
        self.referenceCountingToGLTextureID = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createTextureWithSize:(NSSize)size trackId:(NSInteger)trackId withObjectItemID:(NSInteger)objectItemID{
    
    NSMutableDictionary *trackTextures = [self.textureCollectionToTrackID objectForKey:[NSNumber numberWithInteger:trackId]];

//    NSLog(@"create for id: %ld",objectItemID);

    if (!trackTextures) {
        
        trackTextures = [NSMutableDictionary dictionary];
        [self.textureCollectionToTrackID setObject:trackTextures forKey:[NSNumber numberWithInteger:trackId]];
        
        VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size trackId:trackId];
        [trackTextures setObject:tempTexture forKey:[NSNumber numberWithInteger:(int)(size.width*size.height)]];
        [self.textureToObjectID setObject:tempTexture forKey:[NSNumber numberWithInteger:objectItemID]];
        [self incrementTextureReferenceCounting:tempTexture];

    }
    else {
        
        VSTexture *tempTexture = [trackTextures objectForKey:[NSNumber numberWithInteger:(int)(size.width*size.height)]];

        if (tempTexture == nil) {
            
            // TODO
            // this three lines are exactly the same as above
            tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size trackId:trackId];
            [trackTextures setObject:tempTexture forKey:[NSNumber numberWithInteger:(int)(size.width*size.height)]];
        }
        
        [self.textureToObjectID setObject:tempTexture forKey:[NSNumber numberWithInteger:objectItemID]];
        [self incrementTextureReferenceCounting:tempTexture];

    }
    
//    for (id key in self.textureToObjectID) {
//        NSLog(@"objectID: %@, value: %@", key, [self.textureToObjectID objectForKey:key]);
//    }

}

- (VSTexture *)getVSTextureForTimelineobjectID:(NSInteger)timelineobjectID{
    VSTexture *texture = (VSTexture *)[self.textureToObjectID objectForKey:[NSNumber numberWithInteger:timelineobjectID]];  
    
//    for (id key in self.textureToObjectID) {
//        NSLog(@"objectID: %@, value: %@", key, [self.textureToObjectID objectForKey:key]);
//    }

    if (texture == nil) {
        NSLog(@"fucking shit happens");
    }
    return texture;
}

- (void)deleteTextureForTimelineobjectID:(NSInteger)theID{
  //  NSLog(@"delete for id: %ld",theID);
    VSTexture *texture = [self getVSTextureForTimelineobjectID:theID];
    
    if (texture) {
        [self decrementTextureReferenceCounting:texture];
    }
//    [self printReferenceTable];
}


#pragma mark - Private Methods

/**
 * Incrementing one specific Referencecounter
 * @param texture The reference counter needs the associating VSTexture
 */
- (void)incrementTextureReferenceCounting:(VSTexture *)texture{

    NSNumber *current = (NSNumber *)[self.referenceCountingToGLTextureID objectForKey:[NSNumber numberWithInt:texture.texture]];
    int currentInt;
    
    if (current == nil)
        currentInt = 0;
    else
        currentInt = [current intValue];
    
    currentInt++;
    [self.referenceCountingToGLTextureID setObject:[NSNumber numberWithInt:currentInt]  forKey:[NSNumber numberWithInt:texture.texture]];
  //  [self printReferenceTable];
}

/**
 * Decrement one specific Referencecounter
 * @param texture The reference counter needs the associating VSTexture
 */
- (void)decrementTextureReferenceCounting:(VSTexture *)texture{
    NSNumber *current = (NSNumber *)[self.referenceCountingToGLTextureID objectForKey:[NSNumber numberWithInt:texture.texture]];
    int currentInt;
    
    if (current == nil)
        NSLog(@"Decrementing somethings that not there");
    else
        currentInt = [current intValue];
    
    currentInt--;
    
    if (currentInt == 0) {
        //delete the reference
        [self.referenceCountingToGLTextureID removeObjectForKey:[NSNumber numberWithInt:texture.texture]];
        
        //delete all inside the trackcollection 
        for (id track in self.textureCollectionToTrackID) {            
            NSMutableDictionary *trackDictionary = (NSMutableDictionary *)[self.textureCollectionToTrackID objectForKey:track];
            [trackDictionary removeObjectForKey:[NSNumber numberWithInteger:(int)(texture.size.width*texture.size.height)]];
        }

        //finally delete the real texture on the GL Side
        [texture deleteTexture];
    }
    else{
        [self.referenceCountingToGLTextureID setObject:[NSNumber numberWithInt:currentInt]  forKey:[NSNumber numberWithInt:texture.texture]];
    }
}


/**
 * A simple Printing Method for Debugging.
 */
- (void)printReferenceTable{
    NSLog(@"PrintingReferenceTable");
    for (id key in self.referenceCountingToGLTextureID) {
        NSLog(@"textureID: %@, value: %@", key, [self.referenceCountingToGLTextureID objectForKey:key]);
    }
}

@end
