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
@property (strong) NSMutableDictionary   *textureArray;

@end

@implementation VSTextureManager
@synthesize textureArray = _textureArray;

-(id)init{
    if (self = [super init]) {
        self.textureArray = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (GLuint)createTextureWithSize:(NSSize) size{
    for(VSTexture *vstexture in [_textureArray allValues])
    {
        if (vstexture.size.width == size.width &&
            vstexture.size.height == size.height) {
            NSLog(@"same texture");
            return vstexture.texture;
        }
    }
    
    VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size];
   // [_textureArray addObject:tempTexture];
    [self.textureArray setObject:tempTexture forKey:[NSNumber numberWithInt:tempTexture.texture]];
    
    return tempTexture.texture;
}

- (VSTexture *)getVSTextureForTexId:(GLuint) texId{
    return [self.textureArray objectForKey:[NSNumber numberWithInt:texId]];
}

@end
