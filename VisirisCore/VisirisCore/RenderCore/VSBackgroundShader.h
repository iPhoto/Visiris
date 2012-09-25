//
//  VSBackgroundShader.h
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/24/12.
//
//

#import "VSShader.h"

@interface VSBackgroundShader : VSShader

/** Uniform for the blendTexture */
@property (assign) GLuint       uniformTexture;

/** Position of the Vertices */
@property (assign) GLuint       attributePosition;

@end
