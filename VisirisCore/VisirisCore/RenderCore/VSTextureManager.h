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
 */
- (void)createTextureWithSize:(NSSize)size trackId:(NSInteger)trackId withObjectItemID:(NSInteger)objectItemID;

/**
 * The Manager is organised in Dictionary - TextureID to VSTexture
 * @param timelineobjectID The ID of the TimelineObject
 * @return Returns the corresponding VSTexture
 */
- (VSTexture *)getVSTextureForTimelineobjectID:(NSInteger)timelineobjectID;

/**
 * Is for deleting an Texture to an correspondending Timelineobject (intern it mostly decreases the referencecounting)
 * @param theID The ID of the TimelineObject
 */
- (void)deleteTextureForTimelineobjectID:(NSInteger)theID;

@end
