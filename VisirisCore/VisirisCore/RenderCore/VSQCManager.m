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
@property (strong) NSMutableDictionary   *quartzRendererForId;

@end

@implementation VSQCManager
@synthesize quartzRendererForId = _quartzRendererForId;


- (id)init{
    if (self = [super init]) {
        self.quartzRendererForId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (GLuint)createQCRendererWithSize:(NSSize) size withTrackId:(NSInteger) trackId withPath:(NSString *)path withContext:(NSOpenGLContext *)context withFormat:(NSOpenGLPixelFormat *)format{
    
    //TODO woooot?
    /*
    for(VSQCRenderer *qcRenderer in [self.quartzRendererForId allValues]){
        
        if ([qcRenderer size].width == size.width &&
            [qcRenderer size].height == size.height &&
            qcRenderer.trackId == trackId) {
            
            return [qcRenderer texture];
        }
    }*/
    
    VSQCRenderer *tempRenderer = [[VSQCRenderer alloc] initWithPath:path withSize:size withContext:context withPixelformat:format];
    [self.quartzRendererForId setObject:tempRenderer forKey:[NSNumber numberWithInt:[tempRenderer texture]]];
    
    return [tempRenderer texture];
}

- (VSQCRenderer *)getQCRendererForId:(GLuint) texId{
    return [self.quartzRendererForId objectForKey:[NSNumber numberWithInt:texId]];
}

@end
