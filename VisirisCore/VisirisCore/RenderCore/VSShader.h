//
//  VSShader.h
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Basic Shaderclass handling a program, a vertexshader and a fragmentshader
 */
@interface VSShader : NSObject

/** The Program combines the vertex and the fragmentshader. The Gluint describes the location */
@property (assign) GLuint       program;
            
/** Location of the Vertexshader on the Context */
@property (assign) GLuint       vertexShader;

/** Location of the fragmentshader on the Context */
@property (assign) GLuint       fragmentShader;


/**
 * Initialization using a name. 
 * @param name The name of the Shader (both fragment and vertex). The shader have to be included in the bundle 
 */
-(id)initWithName:(NSString *)name;

@end
