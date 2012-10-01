//
//  VSTransformTexture.h
//  VisirisCore
//
//  Created by Scrat on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSFileKind.h"

/**
 * TransformTextureManager handles FBOs. It is for transforming and rendering a Texture offscreen. It takes a texture and a lot of transforminformation - renders it offscren and transforms it using the transformshader. The final textureId gets returned.
 */
@interface VSTransformTextureManager : NSObject


/**
 * For the initialization is the OpenGLContext needed.
 * @param context The current OpenglContext
 */
- (id)initWithContext:(NSOpenGLContext *)context;


/**
 * This Method gets called every update from each active timelineobject
 * @param texture the TextureID which will be transformed
 * @param trackId Is needed for performance reasons. For each track there is one FBO existing.
 * @param attributes The information for the transformation
 * @param textureSize Size of the inputtexture
 * @param outputSize The Size of the final transformed texture
 * @param qcPatch If the inputtexture is from a QCPatch there are sometimes more options than transforming (not clean solution)
 * @return The textureID of the final transformtexture
 */
- (GLuint)transformTexture:(GLuint)texture atTrack:(NSInteger)trackId withAttributes:(NSDictionary *)attributes withTextureSize:(NSSize)textureSize forOutputSize:(NSSize)outputSize isQCPatch:(BOOL)qcPatch;

/**
 * As soon a Timelineobjects is dropped at an empty Track this Method gets called to create a new FBO
 * @param size The size of the new FBOTexture
 * @param trackId The trackID of the FBO
 */
- (void)createFBOWithSize:(NSSize)size trackId:(NSInteger)trackId;

/**
 * Have to be called when the outputsize changes
 * @param size The size of the new FBOTexture
 */
- (void)resizeOutputSize:(NSSize)size;

//todo
- (void)decrementReferenceCounting:(NSInteger)trackID;

/**
 * CommandLineOutput of the Dictionaries and the referenceCounting
 */
- (void)printDebugLog;

@end
