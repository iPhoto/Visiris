//
//  VSLayerShader.h
//  VisirisCore
//
//  Created by Scrat on 16/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSShader.h"


/**
 * Specific Shader. Uses the layering.fs.glsl and the layering.vs.glsl Shader
 */
@interface VSLayerShader : VSShader

/** Uniform for the blendTexture */
@property (assign) GLuint       uniformTexture1;

/** Uniform for the baseTexture */
@property (assign) GLuint       uniformTexture2;

/** Position of the Vertices */
@property (assign) GLuint       attributePosition;

/** TODO this is obsolete */
@property (assign) GLuint       uniformFadefactor;

@end
