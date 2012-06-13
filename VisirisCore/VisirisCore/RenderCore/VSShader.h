//
//  VSShader.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSShader : NSObject

@property (assign) GLuint       vertexShader;
@property (assign) GLuint       fragmentShader;
@property (assign) GLuint       program;
@property (assign) GLuint       uniformTexture1;
@property (assign) GLuint       uniformTexture2;
@property (assign) GLuint       attributePosition;
@property (assign) GLuint       uniformFadefactor;



@end
