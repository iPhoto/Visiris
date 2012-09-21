//
//  VSQCPManager.m
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQCManager.h"
#import "VSQCRenderer.h"
//#import "VSTexture.h"

@interface VSQCManager()

/** The Dictionary contains the Quartzrenderer and are associated with a TimelineobjectID */
@property (strong) NSMutableDictionary   *quartzRendererForObjectId;

/** The Dictionary contains one VSTexture for each Track */
@property (strong) NSMutableDictionary  *textureForTrackID;


@end

@implementation VSQCManager
@synthesize quartzRendererForObjectId = _quartzRendererForObjectId;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.quartzRendererForObjectId = [[NSMutableDictionary alloc] init];
        self.textureForTrackID = [[NSMutableDictionary alloc] init];
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
    [temp deleteRenderer];
    [self.quartzRendererForObjectId removeObjectForKey:[NSNumber numberWithInteger:timelineObjectID]];
}

- (void)resize:(NSSize)size{
    for (id objectID in self.quartzRendererForObjectId) {
        VSQCRenderer *temp = [self.quartzRendererForObjectId objectForKey:objectID];
        [temp resize:size];
    }
}

- (NSNumber *)createTextureAtTrackId:(NSInteger) trackId{
    
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
    
    //TODO doenst get called - the whole reference Counting is missing
    NSNumber *texture = [self.textureForTrackID objectForKey:[NSNumber numberWithInteger:trackID]];
    GLuint textureName = [texture intValue];
    glDeleteTextures(1, &textureName);
    [self.textureForTrackID removeObjectForKey:[NSNumber numberWithInteger:trackID]];
}

@end
