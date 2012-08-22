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
    
/** The Dictionary contains all the information */
@property (strong) NSMutableDictionary   *texturesForId;

@end

@implementation VSTextureManager
@synthesize texturesForId = _textureArray;

#pragma Mark - Init

-(id)init{
    if (self = [super init]) {
        self.texturesForId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (GLuint)createTextureWithSize:(NSSize) size trackId:(NSInteger) trackId{
    for(VSTexture *vstexture in [_textureArray allValues])
    {
        if (vstexture.size.width == size.width &&
            vstexture.size.height == size.height &&
            vstexture.trackId == trackId) {
            return vstexture.texture;
        }
    }
    
    VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size trackId:trackId];
    [self.texturesForId setObject:tempTexture forKey:[NSNumber numberWithInt:tempTexture.texture]];
    
    return tempTexture.texture;
}

- (VSTexture *)getVSTextureForTexId:(GLuint) texId{
    return [self.texturesForId objectForKey:[NSNumber numberWithInt:texId]];
}

@end
