//
//  VSBackgroundShader.m
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/24/12.
//
//

#import "VSBackgroundShader.h"
#import "OpenGL/glu.h"


@implementation VSBackgroundShader

@synthesize uniformTexture      = _uniformTexture;
@synthesize attributePosition   = _attributePosition;


#pragma mark - Init

- (id)init{
    if (self = [super initWithName:@"background"]) {
        self.uniformTexture = glGetUniformLocation(self.program, "texture");
        self.attributePosition = glGetAttribLocation(self.program, "position");
    }
    return self;
}


@end
