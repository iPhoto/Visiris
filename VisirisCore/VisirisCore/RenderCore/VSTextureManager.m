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
@property (strong) NSMutableArray   *textureArray;

@end

@implementation VSTextureManager
@synthesize textureArray = _textureArray;

-(id)init{
    if (self = [super init]) {
        self.textureArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (GLuint)createTextureWithSize:(NSSize) size{
    for(VSTexture *vstexture in _textureArray)
    {
        if (vstexture.size.width == size.width &&
            vstexture.size.height == size.height) {
            NSLog(@"same texture");
            return vstexture.texture;
        }
    }
    
    VSTexture *tempTexture = [[VSTexture alloc] initEmptyTextureWithSize:size];
    [_textureArray addObject:tempTexture];
    
    return tempTexture.texture;
}

@end
