//
//  VSQCPManager.m
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQCManager.h"
#import "VSQCRenderer.h"


@interface VSQCManager()

/** The Dictionary contains the Quartzrenderer and are associated with a TimelineobjectID */
@property (strong) NSMutableDictionary   *quartzRendererForObjectId;

@end

@implementation VSQCManager
@synthesize quartzRendererForObjectId = _quartzRendererForObjectId;


#pragma Mark - Init

- (id)init{
    if (self = [super init]) {
        self.quartzRendererForObjectId = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - Methods

- (void)createQCRendererWithSize:(NSSize) size withTrackId:(NSInteger) trackId withPath:(NSString *)path withContext:(NSOpenGLContext *)context withFormat:(NSOpenGLPixelFormat *)format withObjectItemID:(NSInteger)objectItemID{
    
    VSQCRenderer *tempRenderer = [[VSQCRenderer alloc] initWithPath:path withSize:size withContext:context withPixelformat:format withTrackID:trackId];
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

@end
