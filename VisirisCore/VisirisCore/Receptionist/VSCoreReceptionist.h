

#import <Foundation/Foundation.h>
#import "VSRenderCore.h"
#import "VSFileKind.h"

@class VSCoreReceptionist;

/**
 * Protocoll the VSCoreReception uses to inform about the state of Rendering in the core
 */
@protocol VSCoreReceptionistDelegate<NSObject>

/**
 * Called when the VSCoreRenderer has returned the newly created frame.
 * @param theCoreReceptionist VSCoreReception which has called the method
 * @param theTimestamp The Timestamp the frame was created for, also used as an ID for the frame.
 * @param theTexture Texture in the Opengl Context of the final Image.
 */
- (void)coreReceptionist:(VSCoreReceptionist *)theCoreReceptionist didFinishedRenderingFrameAtTimestamp:(double)theTimestamp withResultingTexture:(GLuint)theTexture;


@end

/**
 * VSCoreReceptionist is the entry point of the VSCore
 *
 * It sends the frame-data to render to the VSCore and informs its delegates when the frame is done
 */
@interface VSCoreReceptionist : NSObject <VSRenderCoreDelegate>

/** Delegate which is informed when a the rendering was finished */
@property (weak) id<VSCoreReceptionistDelegate>             delegate;

/** VSCoreReceptionist calls the VSRenderCore to create a frame. */
@property (strong) VSRenderCore                             *renderCore;

/**
 * Tells the VSRenderCore to render a frame with the given data.
 * @param aTimestamp The current timestamp of the Visiris Project. Is used as an ID
 * @param theHandovers NSArray of all Handovers 
 * @param theFrameSize The size the frame will be created for.
 */
- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize;


- (GLuint)createNewTextureForSize:(NSSize) textureSize colorMode:(NSString*)colorMode forTrack:(NSInteger)trackID withType:(VSFileKind )type withOutputSize:(NSSize)size withPath:(NSString *)path;

- (void)createNewAudioPlayerWithProjectItemID:(NSInteger)projectItemID withObjectItemID:(NSInteger)objectItemID forTrack:(NSInteger)trackId andFilePath:(NSString *)filepath;

- (void)removeTextureForID:(GLuint) anID;

- (NSOpenGLContext *) openGLContext;

- (void)stopPlaying;

@end