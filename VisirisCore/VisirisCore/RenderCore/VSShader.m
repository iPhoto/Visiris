//
//  VSShader.m
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSShader.h"
#import "OpenGL/glu.h"

/*
static const GLfloat g_vertex_buffer_data[] = { 
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f
};

static const GLushort g_element_buffer_data[] = { 0, 1, 2, 3 };
*/



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

static GLuint make_shader(GLenum type,NSString* name)
{
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


@implementation VSShader
@synthesize fragmentShader = _fragmentShader;
@synthesize program = _program;
@synthesize vertexShader = _vertexShader;
@synthesize uniformTexture1 = _uniformTexture1;
@synthesize uniformTexture2 = _uniformTexture2;
@synthesize attributePosition = _attributePosition;
@synthesize uniformFadefactor = _uniformFadefactor;

-(id)init{
    if (self = [super init]) {
        if ([self make_resources] == 0){
            NSLog(@"Error: Making Resources Failed!!!!!");
        }
    }
    
    return self;
}

-(GLuint)make_buffer:(GLenum)target data:(const void *)buffer_data size:(GLsizei) buffer_size{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, buffer_size, buffer_data, GL_STATIC_DRAW);
    return buffer;
}

- (NSInteger)make_resources
{
    //create buffer
    //g_resources.vertex_buffer = make_buffer(GL_ARRAY_BUFFER,g_vertex_buffer_data,sizeof(g_vertex_buffer_data));
    
    
    
    //g_resources.element_buffer = make_buffer(GL_ELEMENT_ARRAY_BUFFER,g_element_buffer_data,sizeof(g_element_buffer_data));
    
    //create textures
    //g_resources.textures[0] = [[[VSTexture alloc] initWithName:@"jolandabregenz"] texture];
    //g_resources.textures[1] = [[[VSTexture alloc] initWithName:@"test"] texture];
    
   // if (g_resources.textures[0] == 0 || g_resources.textures[1] == 0)
   //     return 0;
    
    
    //compile shader
    self.vertexShader = [self compileShader:@"hellogl.vs" withType:GL_VERTEX_SHADER];
    
    if (self.vertexShader == 0)
        return 0;
    
    
    self.fragmentShader = make_shader(GL_FRAGMENT_SHADER, @"hellogl.fs");
    
    if (self.fragmentShader == 0)
        return 0;
    
    //create shaderprogram
    self.program = [self make_program:self.vertexShader fragmentshader:(self.fragmentShader)];
    //self.program = make_program(g_resources.vertex_shader, g_resources.fragment_shader);
    if (self.program == 0)
        return 0;
    
    self.uniformFadefactor = glGetUniformLocation(self.program, "fade_factor");
    self.uniformTexture1 = glGetUniformLocation(self.program, "textures[0]");
    self.uniformTexture2 = glGetUniformLocation(self.program, "textures[1]");
    
    self.attributePosition = glGetAttribLocation(self.program, "position");
    
    return 1;
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
        //   show_info_log(program, glGetProgramiv, glGetProgramInfoLog);
        glDeleteProgram(program);
        return 0;
    }
    return program;
}

@end
