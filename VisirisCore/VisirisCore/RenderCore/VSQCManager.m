//
//  VSQCPManager.m
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQCManager.h"
#import "VSQCRenderer.h"
#import "VSReferenceCounting.h"

@interface VSQCManager()

/** The Dictionary contains the Quartzrenderer and are associated with a TimelineobjectID */
@property (strong) NSMutableDictionary      *quartzRendererForObjectId;

/** The Dictionary contains one VSTexture for each Track */
@property (strong) NSMutableDictionary      *textureForTrackID;

/** Counts the number of quartzObjects for each track */
@property (strong) VSReferenceCounting      *referenceCountingObjects;

@end


@implementation VSQCManager
@synthesize quartzRendererForObjectId = _quartzRendererForObjectId;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.quartzRendererForObjectId = [[NSMutableDictionary alloc] init];
        self.textureForTrackID = [[NSMutableDictionary alloc] init];
        self.referenceCountingObjects = [[VSReferenceCounting alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createQCRendererWithSize:(NSSize)size withTrackId:(NSInteger) trackId withPath:(NSString *)path withContext:(NSOpenGLContext *)context withFormat:(NSOpenGLPixelFormat *)format withObjectItemID:(NSInteger)objectItemID{
    
    NSNumber *texture = [self createTextureAtTrackId:trackId];
    
    VSQCRenderer *tempRenderer = [[VSQCRenderer alloc] initWithPath:path
                                                           withSize:size
                                                        withContext:context
                                                    withPixelformat:format
                                                        withTrackID:trackId
                                                        withTexture:texture];
    
    [self.quartzRendererForObjectId setObject:tempRenderer forKey:[NSNumber numberWithInteger:objectItemID]];
}
 
- (VSQCRenderer *)getQCRendererForObjectId:(NSInteger)objectID{
    return [self.quartzRendererForObjectId objectForKey:[NSNumber numberWithInteger:objectID]];
}

- (void)deleteQCRenderer:(NSInteger)timelineObjectID{
   
    VSQCRenderer *temp = [self.quartzRendererForObjectId objectForKey:[NSNumber numberWithInteger:timelineObjectID]];
    if (temp) {
        
        if([self.referenceCountingObjects decrementReferenceOfKey:[NSNumber numberWithInteger:temp.trackId]] == NO){
            [self deleteTextureForTrackID:temp.trackId];
        }
        
        [self.quartzRendererForObjectId removeObjectForKey:[NSNumber numberWithInteger:timelineObjectID]];
    }
}

- (void)resize:(NSSize)size{
    for (id objectID in self.quartzRendererForObjectId) {
        VSQCRenderer *temp = [self.quartzRendererForObjectId objectForKey:objectID];
        [temp resize:size];
    }
}

- (NSNumber *)createTextureAtTrackId:(NSInteger)trackId{
    
    [self.referenceCountingObjects incrementReferenceOfKey:[NSNumber numberWithInteger:trackId]];
    
    NSNumber *texture = [self.textureForTrackID objectForKey:[NSNumber numberWithInteger:trackId]];
    
    if (texture) {
        return texture;
    }
    
    GLuint textureName;
    glGenTextures(1, &textureName);
    glBindTexture(GL_TEXTURE_2D, textureName);    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    texture = [NSNumber numberWithInt:textureName];
    
    [self.textureForTrackID setObject:texture forKey:[NSNumber numberWithInteger:trackId]];
    return texture;
}

- (void)deleteTextureForTrackID:(NSInteger)trackID{
    
    NSNumber *texture = [self.textureForTrackID objectForKey:[NSNumber numberWithInteger:trackID]];
    GLuint textureName = [texture intValue];
    glDeleteTextures(1, &textureName);
    [self.textureForTrackID removeObjectForKey:[NSNumber numberWithInteger:trackID]];
}

- (void)printDebugLog{
    NSLog(@"++++++++++++++++++++++++++DEBUG LOG VSQC MANAGER++++++++++++++++++++++++++");
    NSLog(@"-----quartzRendererForObjectId-----");
    for (id objectID in self.quartzRendererForObjectId) {
        NSLog(@"objectID: %@, quartzRenderer: %@", objectID, [self.quartzRendererForObjectId objectForKey:objectID]);
    }
    
    NSLog(@"-----textureForTrackID-----");
    for (id trackID in self.textureForTrackID) {
        NSLog(@"trackID: %@, texture: %@", trackID, [self.textureForTrackID objectForKey:trackID]);
    }
    
    NSLog(@"-----referenceCountingObjects-----");
    [self.referenceCountingObjects printDebugLog];
}

- (NSInteger)trackIDfromObjectID:(NSInteger)objectID{
    
    VSQCRenderer *tempRenderer = [self.quartzRendererForObjectId objectForKey:[NSNumber numberWithInteger:objectID]];
    return tempRenderer.trackId;
}


@end
