//
//  VSTransformShader.m
//  VisirisCore
//
//  Created by Scrat on 16/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTransformShader.h"
#import "OpenGL/glu.h"

@implementation VSTransformShader

@synthesize uniformTexture = _uniformTexture;
@synthesize attributePosition = _attributePosition;

- (id)init{
    if (self = [super initWithName:@"transform"]) {
        self.uniformTexture = glGetUniformLocation(self.program, "textures[0]");
        
        self.attributePosition = glGetAttribLocation(self.program, "position");
    }
    return self;
}

@end
