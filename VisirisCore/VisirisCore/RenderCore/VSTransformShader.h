//
//  VSTransformShader.h
//  VisirisCore
//
//  Created by Scrat on 16/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSShader.h"

@interface VSTransformShader : VSShader

@property (assign) GLuint   attributePosition;
@property (assign) GLuint   uniformTexture;
@property (assign) GLuint   uniformObjectWidth;
@property (assign) GLuint   uniformObjectHeight;
@property (assign) GLuint   uniformWindowWidth;
@property (assign) GLuint   uniformWindowHeight;
@property (assign) GLuint   uniformScaleX;
@property (assign) GLuint   uniformScaleY;
@property (assign) GLuint   uniformRotateX;
@property (assign) GLuint   uniformRotateY;
@property (assign) GLuint   uniformRotateZ;
@property (assign) GLuint   uniformTranslateX;
@property (assign) GLuint   uniformTranslateY;
@property (assign) GLuint   uniformTranslateZ;
@property (assign) GLuint   uniformIsQCPatch;

@end
