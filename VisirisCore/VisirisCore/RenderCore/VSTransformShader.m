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

@synthesize uniformTexture              = _uniformTexture;
@synthesize attributePosition           = _attributePosition;
@synthesize uniformObjectWidth          = _uniformObjectWidth;
@synthesize uniformObjectHeight         = _uniformObjectHeight;
@synthesize uniformWindowWidth          = _uniformWindowWidth;
@synthesize uniformWindowHeight         = _uniformWindowHeight;
@synthesize uniformScaleX               = _scaleX;
@synthesize uniformScaleY               = _scaleY;
@synthesize uniformRotateX              = _uniformRotateX;
@synthesize uniformRotateY              = _uniformRotateY;
@synthesize uniformRotateZ              = _uniformRotateZ;
@synthesize uniformTranslateX           = _uniformTranslateX;
@synthesize uniformTranslateY           = _uniformTranslateY;
@synthesize uniformTranslateZ           = _uniformTranslateZ;
@synthesize uniformIsQCPatch            = _uniformIsQCPatch;
@synthesize uniformAlpha                = _uniformAlpha;


#pragma Mark - Init

- (id)init{
    if (self = [super initWithName:@"transform"]) {
        self.attributePosition          = glGetAttribLocation(self.program, "position");

        self.uniformTexture             = glGetUniformLocation(self.program, "texture");
        self.uniformObjectWidth         = glGetUniformLocation(self.program, "objectWidth");
        self.uniformObjectHeight        = glGetUniformLocation(self.program, "objectHeight");
        self.uniformWindowWidth         = glGetUniformLocation(self.program, "windowWidth");
        self.uniformWindowHeight        = glGetUniformLocation(self.program, "windowHeight");
        self.uniformScaleX              = glGetUniformLocation(self.program, "scaleX");
        self.uniformScaleY              = glGetUniformLocation(self.program, "scaleY");
        self.uniformRotateX             = glGetUniformLocation(self.program, "rotateX");
        self.uniformRotateY             = glGetUniformLocation(self.program, "rotateY");
        self.uniformRotateZ             = glGetUniformLocation(self.program, "rotateZ");
        self.uniformTranslateX          = glGetUniformLocation(self.program, "translateX");
        self.uniformTranslateY          = glGetUniformLocation(self.program, "translateY");
        self.uniformTranslateZ          = glGetUniformLocation(self.program, "translateZ");
        self.uniformIsQCPatch           = glGetUniformLocation(self.program, "isQCPatch");
        self.uniformAlpha               = glGetUniformLocation(self.program, "alpha");
    }
    return self;
}

@end
