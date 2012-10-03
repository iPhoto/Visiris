//
//  VisirisCore.h
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSFileKind.h"

@class VSFrameBufferObject;
@class VSRenderCore;
@class VSTexture;
@class VSShader;
@class VSTextureManager;
@class VSQCManager;

/**
 * Protocoll the VSRenderCore uses to inform about the rendering states
 */
@protocol VSRenderCoreDelegate<NSObject>

@required

/**
 * Is called when the rendering of a frame was done
 * @param theRenderCore VSRenderCore which has called the mehtod.
 * @param theFinalFrame the frame that was rendered.
 * @param theTimestamp The timestamp the frame was rendered for.
 */
- (void)renderCore:(VSRenderCore *)theRenderCore didFinishRenderingTexture:(GLuint)theTexture forTimestamp:(double) theTimestamp;

@end


/**
 * Creates the final Texture
 *
 * In the Rendercore Textures are created with the Info of the Handovers. These Textures are merged correctly together to one final Texture which is returned at the and of the renderprocess.
 */
@interface VSRenderCore : NSObject


/**
 * Initialization if the Rendercore
 * @param size The size is needed for creating FBO Textures ec.
 */
-(id)initWithSize:(NSSize)size;

/** Delegate for Communicating with the Receptionist */
@property (weak) id<VSRenderCoreDelegate>           delegate;

/**
 * Creates one frame out of the data stored in the give VSCoreHandovers in the given frame size.
 * @param theCoreHandovers NSArray storing the handover objects the frame will be created of.
 * @param theFrameSize The frame size the frame will be created for.
 * @param theTimestamp Timestamp the frame was rendered for for.
 */
-(void)renderFrameOfCoreHandovers:(NSArray *)theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double) theTimestamp;

/**
 * When a object is dropped on the timeline it needs a reference to a texture in the openglcontext for performance reasons. When the size and the track is new the core creates a new texture. 
 * @param textureSize Size of the texture
 * @param colorMode Currently unused - later to create a texture with or without alpha (optimization)
 * @param trackID Each track has it own textures
 * @param type The Type is Image, Video, Quartzcomposer or Audio
 * @param size The size of the Output (not preview)
 * @param path Needed for Quartzcomposer patches
 */
-(void)createNewTextureForSize:(NSSize)textureSize colorMode:(NSString*)colorMode forTrack:(NSInteger)trackID withType:(VSFileKind)type withOutputSize:(NSSize)size withPath:(NSString *)path withObjectItemID:(NSInteger)objectItemID;

/**
 * @return the OpenglContext
 */
- (NSOpenGLContext *)openglContext;

/**
 * Deletes a Texture referencing of a TimelineobjectID
 * @param theID Individual ID of an Timelineobject
 */
- (void)deleteTextureFortimelineobjectID:(NSInteger)theID;

/**
 * Deletes a QCRenderer referencing of a TimelineobjectID
 * @param theID Individual ID of an Timelineobject
 */
- (void)deleteQCPatchForTimelineObjectID:(NSInteger)theID;

/**
 * Print output of the manager.
 */
- (void)printDebugLog;

@end
