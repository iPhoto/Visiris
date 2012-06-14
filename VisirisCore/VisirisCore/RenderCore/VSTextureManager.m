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
@property (strong) NSMutableDictionary   *texturesForId;

@end

@implementation VSTextureManager
@synthesize texturesForId = _textureArray;

-(id)init{
    if (self = [super init]) {
        self.texturesForId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (GLuint)createTextureWithSize:(NSSize) size{
    for(VSTexture *vstexture in [_textureArray allValues])
    {
        if (vstexture.size.width == size.width &&
            vstexture.size.height == size.height) {
            return vstexture.texture;
        }
    }
    
    VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size];
    [self.texturesForId setObject:tempTexture forKey:[NSNumber numberWithInt:tempTexture.texture]];
    
    return tempTexture.texture;
}

- (VSTexture *)getVSTextureForTexId:(GLuint) texId{
    return [self.texturesForId objectForKey:[NSNumber numberWithInt:texId]];
}

@end
