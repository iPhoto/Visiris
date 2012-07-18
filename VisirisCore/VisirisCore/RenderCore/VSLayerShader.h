//
//  VSLayerShader.h
//  VisirisCore
//
//  Created by Scrat on 16/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSShader.h"

@interface VSLayerShader : VSShader

@property (assign) GLuint       uniformTexture1;
@property (assign) GLuint       uniformTexture2;
@property (assign) GLuint       attributePosition;
@property (assign) GLuint       uniformFadefactor;

@end
