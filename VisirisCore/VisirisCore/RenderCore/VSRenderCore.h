//
//  VisirisCore.h
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSFrameBufferObject;
@class VSRenderCore;
@class VSTexture;
@class VSShader;
@class VSTextureManager;

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

@interface VSRenderCore : NSObject

@property (weak) id<VSRenderCoreDelegate>           delegate;
@property (strong, readonly) NSOpenGLContext        *openGLContext;
@property (strong, readonly) NSOpenGLPixelFormat    *pixelFormat;        
@property (strong) VSFrameBufferObject              *frameBufferObjectOne;
@property (strong) VSTexture                        *textureBelow;
@property (strong) VSTexture                        *textureUp;
@property (strong) VSShader                         *shader;
@property (strong) VSTextureManager                 *textureManager;

/**
 * Creates one frame out of the data stored in the give VSCoreHandovers in the given frame size.
 * @param theCoreHandovers NSArray storing the handover objects the frame will be created of.
 * @param theFrameSize The frame size the frame will be created for.
 * @param theTimestamp Timestamp the frame was rendered for for.
 */
-(void)renderFrameOfCoreHandovers:(NSArray *)theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double) theTimestamp;

@end
