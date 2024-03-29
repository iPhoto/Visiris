//
//  VSQCRenderer.h
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTexture.h"

/**
 * VSQCRenderer is able to render a basic QuartzComposerPatch
 */
@interface VSQCRenderer : NSObject

/** ID of the TimelineObject */
@property (readonly, assign) NSInteger  timeLineObjectId;

/** The TrackID of the TimelineObject */
@property (readonly, assign) NSInteger  trackId;

/** The size of the Texture */
@property (assign) NSSize               size;


/**
 * The Basic Initialization includes all the necessary information
 * @param path The absolute Path on the harddrive of the patch
 * @param size The size for the new created Texture
 * @param context The OpenGLContext
 * @param format The Format for the OpenGLCOntext
 * @param trackid The TrackID of the TimelineObject
 */
- (id)initWithPath:(NSString *)path withSize:(NSSize)size withContext:(NSOpenGLContext *)context withPixelformat:(NSOpenGLPixelFormat *)format withTrackID:(NSInteger)trackid withTexture:(NSNumber *)texture;

/**
 * Updates and returns the Texture
 * @param time The actual time is needed for updating the renderer
 * @return textureID
 */
- (GLuint)renderAtTme:(double)time;

/**
 * Depending on the Patch it is possible to set Inputvalues which alter the effect
 * @param inputValues The Dictionary containing all the information of the values
 */
- (void)setPublicInputsWithValues:(NSDictionary*)inputValues;

/**
 * Resizes the texture
 * @param size The new Size
 */
- (void)resize:(NSSize)size;


@end
