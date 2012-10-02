//
//  VSQCPManager.h
//  VisirisCore
//
//  Created by Scrat on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSQCRenderer;

/**
 * Manages Quartzrenderer. 
 */
@interface VSQCManager : NSObject

/**
 * Creates a Quartzrenderer. Gets called as soon a Timlineobject gets dropped on the timeline - representing a timelineobject.
 * @param size The dimension of the Texture
 * @param trackId The Track of the timelineobject.
 * @param path The Path of the Quartzcomposerpatch on the Harddrive
 * @param context The OpenGLContext
 * @param format The format of the Context
 * @param objectIdemID The ID of the associating TimelineObject
 */
- (void)createQCRendererWithSize:(NSSize)size withTrackId:(NSInteger)trackId withPath:(NSString *)path withContext:(NSOpenGLContext *)context withFormat:(NSOpenGLPixelFormat *)format withObjectItemID:(NSInteger)objectItemID;

/**
 * Returns the VSQCRenderer for the TimelinieObjectID
 * @param objectID The TimelineobjectID
 * @return VSQCRenderer of the correspondending ID
 */
- (VSQCRenderer *)getQCRendererForObjectId:(NSInteger)objectID;


/**
 * Deletes the QCRenderer associated with a timelineobject
 * @param timelineObjectID The ID of the timelineObject
 */
- (void)deleteQCRenderer:(NSInteger)timelineObjectID;

/**
 * Resizes the outputTexture
 * @param size The new Size of the output
 */
- (void)resize:(NSSize)size;

/**
 * Printing out all container which are holding strong objects
 */
- (void)printDebugLog;

/**
 * Returns the trackID given the ID of a timelineobject
 * @param objectID ID of the timelineObject
 * @return ID of the Track
 */
- (NSInteger)trackIDfromObjectID:(NSInteger)objectID;


@end
