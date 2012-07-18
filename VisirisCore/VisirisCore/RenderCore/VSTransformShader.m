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

@synthesize uniformTexture      = _uniformTexture;
@synthesize attributePosition   = _attributePosition;
@synthesize uniformScale        = _scale;

- (id)init{
    if (self = [super initWithName:@"transform"]) {
        self.uniformTexture = glGetUniformLocation(self.program, "texture");
        self.uniformScale = glGetUniformLocation(self.program, "scale");
        
        self.attributePosition = glGetAttribLocation(self.program, "position");

    }
    return self;
}

@end
