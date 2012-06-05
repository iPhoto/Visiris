//
//  VSShader.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 static struct {
 GLuint vertex_buffer, element_buffer;
 // GLuint textures[2];
 GLuint vertex_shader, fragment_shader, program;
 
 struct {
 GLint fade_factor;
 GLint textures[2];
 } uniforms;
 
 struct {
 GLint position;
 } attributes;
 
 GLfloat fade_factor;
 } g_resources;
 */

@interface VSShader : NSObject
//@property (assign) GLuint       vertexBuffer;
//@property (assign) GLuint       elementBuffer;
@property (assign) GLuint       vertexShader;
@property (assign) GLuint       fragmentShader;
@property (assign) GLuint       program;
@property (assign) GLuint       uniformTexture1;
@property (assign) GLuint       uniformTexture2;
@property (assign) GLuint       attributePosition;
@property (assign) GLuint       uniformFadefactor;



@end
