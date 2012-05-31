

#import <Foundation/Foundation.h>
#import "VSRenderCore.h"

@class VSCoreReceptionist;

/**
 * Protocoll the VSCoreReception uses to inform about the state of Rendering in the core
 */
@protocol VSCoreReceptionistDelegate<NSObject>

/**
 * Called when the VSCoreRenderer has returned the newly created frame.
 * @param theCoreReceptionist VSCoreReception which has called the method
 * @param aTimestamp The Timestamp the frame was created for, also used as an ID for the frame.
 * @param theNewFrame Pointer to the newly created frame.
 */
- (void)coreReceptionist:(VSCoreReceptionist *)theCoreReceptionist didFinishedRenderingFrameAtTimestamp:(double)aTimestamp withResultingFrame:(char *)theNewFrame;


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
 * @param theAttributes NSDictionary containing the parameter values for the frame at the given timestamp. The type-Property of VSParameter is used as Key as declared in VSParameterType
 * @param theFrameSize The size the frame will be created for.
 */
- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize;

- (NSOpenGLContext *) openGLContext;

@end