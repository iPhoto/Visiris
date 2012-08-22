//
//  VSTexture.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSImage;

/**
 * VSTexture is for handling OpenGL Texture spefically designed for Visiris.
 */
@interface VSTexture : NSObject

/** The actual Texture */
@property (readonly, assign) GLuint     texture;

/** The size of the texture */
@property (readonly, assign) NSSize     size;

/** The ID of the timelineobject */
@property (readonly, assign) NSInteger  timeLineObjectId;

/** The Track on which the timelineobject is at */
@property (readonly, assign) NSInteger  trackId;


/**
 * Inits with size and the trackID
 * @param size Size of the new created Texture
 * @param trackId The TrackID of the Timelineobject 
 */
- (id)initEmptyTextureWithSize:(NSSize) size trackId:(NSInteger) trackId;

/**
 * Doesn't desroy and recreate a texture. Uses the same texture - just replaces the content. Good for performance.
 * @param theImage Contains the information of the new Texture
 * @param timeLineObjectId The ID of the Timelineobject
 */
- (void)replaceContent:(VSImage *)theImage timeLineObjectId:(NSInteger)timeLineObjectId;

/** Bind the Texture in the current active OpenGL Context */
- (void)bind;

/** Unbind the Texture in the current active OpenGL Context */
- (void)unbind;

/** Completely deletes the Texture */
- (void)deleteTexture;

@end
