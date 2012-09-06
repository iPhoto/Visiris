//
//  VSTextureManager.h
//  VisirisCore
//
//  Created by Scrat on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSTexture;

/**
 * VSTextureManager manages VSTextures
 */
@interface VSTextureManager : NSObject

/**
 * Creates a Texture with a specific size and for a specific track. Gets called as soon as there is a new TimelineObject.
 * @param size The size of the new Texture
 * @param trackId The Track on which the Timelineobject is
 * @return TextureID of the OpenGLContext
 */
- (GLuint)createTextureWithSize:(NSSize)size trackId:(NSInteger)trackId;

/**
 * The Manager is organised in Dictionary - TextureID to VSTexture
 * @param texId The TextureId
 * @return Returns the corresponding VSTexture
 */
- (VSTexture *)getVSTextureForTexId:(GLuint)texId;

@end
