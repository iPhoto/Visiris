//
//  VSShader.m
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSShader.h"
#import "OpenGL/glu.h"

@implementation VSShader

@synthesize program = _program;
@synthesize fragmentShader = _fragmentShader;
@synthesize vertexShader = _vertexShader;

-(id)initWithName:(NSString *)name {
    if (self = [super init]) {
        if ([self make_resources:name] == 0){
            NSLog(@"Error: Making Resources Failed!!!!!");
        }
    }
    return self;
}

- (NSInteger)make_resources:(NSString *)name{
    //compile shader
    self.vertexShader = [self compileShader:[NSString stringWithFormat:@"%@.vs",name]  withType:GL_VERTEX_SHADER];
    
    if (self.vertexShader == 0)
        return 0;
    
    self.fragmentShader =[self make_shader:GL_FRAGMENT_SHADER withName:[NSString stringWithFormat:@"%@.fs",name]];
    
    if (self.fragmentShader == 0)
        return 0;
    
    //create shaderprogram
    self.program = [self make_program:self.vertexShader fragmentshader:(self.fragmentShader)];
    if (self.program == 0)
        return 0;
        
    return 1;
}

- (GLuint)make_shader:(GLenum) type withName:(NSString*) name{
    NSString* shaderPath = [[NSBundle bundleWithIdentifier:@"com.visiris.VisirisCore"] pathForResource:name ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLint length;
    GLuint shader;
    GLint shader_ok;
    
    shader = glCreateShader(type);    
    
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    length = [shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &length);
    
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &shader_ok);
    if (!shader_ok) {
        NSLog(@"something went wront");
        glDeleteShader(shader);
        return 0;
    }
    
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shader;
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    NSString* shaderPath = [[NSBundle bundleWithIdentifier:@"com.visiris.VisirisCore"] pathForResource:shaderName ofType:@"glsl"];
    
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"Error: %@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (GLuint)make_program:(GLuint)vertex_shader fragmentshader:(GLuint)fragment_shader{
    GLint program_ok;
    
    GLuint program = glCreateProgram();
    
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &program_ok);
    if (!program_ok) {
        fprintf(stderr, "Failed to link shader program:\n");
        glDeleteProgram(program);
        return 0;
    }
    return program;
}

@end
