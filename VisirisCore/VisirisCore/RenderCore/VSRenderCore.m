//
//  VisirisCore.m
//  VisirisCore
//
//  Created by Martin Tiefengrabner on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSRenderCore.h"
#import "VSFrameCoreHandover.h"
#import "VSQuartzComposerHandover.h"
#import "VSFrameBufferObject.h"
#import "VSTexture.h"
#import "VSShader.h"
#import <OpenGL/glu.h>

//FixeMe: Warum sind die static Methoden außerhalb der Klasse definiert?

static const GLfloat g_vertex_buffer_data[] = { 
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f
};

static const GLushort g_element_buffer_data[] = { 0, 1, 2, 3 };

static GLuint make_buffer(GLenum target,const void *buffer_data,GLsizei buffer_size) {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, buffer_size, buffer_data, GL_STATIC_DRAW);
    return buffer;
}

static struct {
    GLuint vertex_buffer, element_buffer;
 /*   GLuint textures[2];
    GLuint vertex_shader, fragment_shader, program;
    
    struct {
        GLint fade_factor;
        GLint textures[2];
    } uniforms;
    
    struct {
        GLint position;
    } attributes;
    
    GLfloat fade_factor;*/
} g_resources;
/*
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

static GLuint make_program(GLuint vertex_shader, GLuint fragment_shader)
{
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
*/
@implementation VSRenderCore
@synthesize delegate = _delegate;
@synthesize pixelFormat = _pixelFormat;
@synthesize openGLContext = _openGLContext;
@synthesize frameBufferObjectOne = _frameBufferObjectOne;
@synthesize textureBelow = _textureBelow;
@synthesize textureUp = _textureUp;
@synthesize shader = _shader;

-(id)init{
    
    self = [super init];
    if (self) {
        
        NSOpenGLPixelFormatAttribute attribs[] =
        {
            kCGLPFAAccelerated,
            kCGLPFANoRecovery,
            kCGLPFADoubleBuffer,
            kCGLPFAColorSize, 24,
            kCGLPFADepthSize, 16,
            0
        };
        
        _pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
        
        if (!_pixelFormat)
            NSLog(@"No OpenGL pixel format");
        
        // NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
        _openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
        
        [ _openGLContext makeCurrentContext];
        
        GLint swapInt = 1;
		[ _openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
		
        
        if([self make_resources] == 0){
            NSLog(@"Error: Making Resources Failed!!!!!");
        }
        
        self.frameBufferObjectOne = [[VSFrameBufferObject alloc] init];
        
        self.shader = [[VSShader alloc] init];
        
    }
    return self;
}


-(void)renderFrameOfCoreHandovers:(NSArray *) theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double)theTimestamp{
    NSMutableArray *mutableCoreHandovers = [NSMutableArray arrayWithArray:theCoreHandovers];
    
    for(VSCoreHandover *coreHandover in theCoreHandovers){
        if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            VSFrameCoreHandover *convertedQuartzComposerHandover = [self createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) coreHandover];
            [mutableCoreHandovers replaceObjectAtIndex:[mutableCoreHandovers indexOfObject:coreHandover] withObject:convertedQuartzComposerHandover];
        }
    }
        
    if ([mutableCoreHandovers count] < 2) {
        return;
    }
        
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
	
	// Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
    
    self.textureBelow = [[VSTexture alloc] initWithNSImage:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:0]).frame];
    self.textureUp = [[VSTexture alloc] initWithNSImage:((VSFrameCoreHandover*)[mutableCoreHandovers objectAtIndex:1]).frame];
    
    GLuint finalTexture = [self combineTexture:self.textureBelow.texture with:self.textureUp.texture];
    
    GLint texSize;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &texSize); 
    NSLog(@"blubb: %d", texSize);

  //  GLuint finalTexture = [self combineTexture:g_resources.textures[0] with:g_resources.textures[1]];
    
    	
    [self.textureBelow deleteTexture];
    [self.textureUp deleteTexture];
    
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
    
    NSLog(@"renderFrameOfCoreHandovers");
   // return;
    
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(renderCore:didFinishRenderingTexture:forTimestamp:)]) {
            [self.delegate renderCore:self didFinishRenderingTexture:finalTexture forTimestamp:theTimestamp];
        }
    }
}

- (GLuint)combineTexture:(GLuint)bottomtexture with:(GLuint)upperTexture
{	
    [self.frameBufferObjectOne bind];
    
    glViewport(0, 0, self.frameBufferObjectOne.size.width,self.frameBufferObjectOne.size.height);
    
    
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
   // g_resources.fade_factor = 0.5;
    
    glUseProgram(self.shader.program);
    glUniform1f(self.shader.uniformFadefactor, 0.5f);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, bottomtexture);
    glUniform1i(self.shader.uniformTexture1, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, upperTexture);
    glUniform1i(self.shader.uniformTexture2, 1);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, g_resources.vertex_buffer);
    glVertexAttribPointer(self.shader.attributePosition,  /* attribute */
                          2,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*2,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(self.shader.attributePosition);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_resources.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
    glDisableVertexAttribArray(self.shader.attributePosition);
    
    [self.frameBufferObjectOne unbind];
    return self.frameBufferObjectOne.texture;
}

-(VSFrameCoreHandover *) createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) quartzComposerHandover{
    
    VSFrameCoreHandover *coreHandover = nil;
    
    if (quartzComposerHandover) {
        
    }
    
    return coreHandover;
}


- (NSInteger)make_resources
{
    //create buffer
    g_resources.vertex_buffer = make_buffer(GL_ARRAY_BUFFER,g_vertex_buffer_data,sizeof(g_vertex_buffer_data));
    
    g_resources.element_buffer = make_buffer(GL_ELEMENT_ARRAY_BUFFER,g_element_buffer_data,sizeof(g_element_buffer_data));
    /*
    //create textures
    g_resources.textures[0] = [[[VSTexture alloc] initWithName:@"jolandabregenz"] texture];
    g_resources.textures[1] = [[[VSTexture alloc] initWithName:@"test"] texture];
    
    if (g_resources.textures[0] == 0 || g_resources.textures[1] == 0)
        return 0;

    
    //compile shader
    g_resources.vertex_shader = [self compileShader:@"hellogl.vs" withType:GL_VERTEX_SHADER];
    
    if (g_resources.vertex_shader == 0)
        return 0;
    
    g_resources.fragment_shader = make_shader(GL_FRAGMENT_SHADER, @"hellogl.fs");
    
    if (g_resources.fragment_shader == 0)
        return 0;
    
    //create shaderprogram
    g_resources.program = make_program(g_resources.vertex_shader, g_resources.fragment_shader);
    if (g_resources.program == 0)
        return 0;
    
    g_resources.uniforms.fade_factor = glGetUniformLocation(g_resources.program, "fade_factor");
    g_resources.uniforms.textures[0] = glGetUniformLocation(g_resources.program, "textures[0]");
    g_resources.uniforms.textures[1] = glGetUniformLocation(g_resources.program, "textures[1]");
    
    g_resources.attributes.position = glGetAttribLocation(g_resources.program, "position");
    */
    return 1;
}
/*
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
    
//    return shaderHandle;instru
}
*/


@end
