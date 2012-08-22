//
//  VSFrameBufferObject.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Abstract class for creating a Framebuffer Object the easiest way possible
 */
@interface VSFrameBufferObject : NSObject

/** A Framebuffer does need a texture in order to render Offscreen */
@property (readonly, assign) GLuint     texture;

/** The size of the texture */
@property (readonly, assign) NSSize     size;

/**
 * Basic Init Method. Calls initWithSize with 640, 480
 */
- (id)init;

/**
 * Abstract class for creating a Framebuffer Object the easiest way possible
 * @param size The size of the Texture
 */
- (id)initWithSize:(NSSize)size;

/**
 * Binding the FBO
 */
- (void)bind;

/**
 * Unbinding the FBO
 */
- (void)unbind;

/**
 * Resizing the Texture of the FBO
 * @param size The new Size
 */
- (void)resize:(NSSize)size;

@end
