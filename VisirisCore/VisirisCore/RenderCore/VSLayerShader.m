//
//  VSLayerShader.m
//  VisirisCore
//
//  Created by Scrat on 16/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSLayerShader.h"
#import "OpenGL/glu.h"

@implementation VSLayerShader

@synthesize uniformTexture1 = _uniformTexture1;
@synthesize uniformTexture2 = _uniformTexture2;
@synthesize attributePosition = _attributePosition;
@synthesize uniformFadefactor = _uniformFadefactor;

- (id)init{
    if (self = [super initWithName:@"layering"]) {
        self.uniformFadefactor = glGetUniformLocation(self.program, "fade_factor");
        self.uniformTexture1 = glGetUniformLocation(self.program, "textures[0]");
        self.uniformTexture2 = glGetUniformLocation(self.program, "textures[1]");
        
        self.attributePosition = glGetAttribLocation(self.program, "position");

    }
    return self;
}


@end
