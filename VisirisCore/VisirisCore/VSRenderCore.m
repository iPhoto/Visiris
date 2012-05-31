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
#import <OpenGL/glu.h>


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
    GLuint textures[2];
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


@interface VSRenderCore ()

-(GLuint) getVideoTextureFromNSImage:(NSImage *)inimage;


@end

@implementation VSRenderCore
@synthesize delegate = _delegate;
@synthesize pixelFormat = _pixelFormat;
@synthesize openGLContext = _openGLContext;
@synthesize frameBuffer = _frameBuffer;
@synthesize texture = _texture;

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
        
        
        /////// creating framebuffer
        /*_frameBuffer = 0;
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        // The texture we're going to render to
        GLuint renderedTexture;
        glGenTextures(1, &renderedTexture);
        
        // "Bind" the newly created texture : all future texture functions will modify this texture
        glBindTexture(GL_TEXTURE_2D, renderedTexture);
        
        // Give an empty image to OpenGL ( the last "0" )
        glTexImage2D(GL_TEXTURE_2D, 0,GL_RGB, 1024, 768, 0,GL_RGB, GL_UNSIGNED_BYTE, 0);
        
        // Poor filtering. Needed !
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        
        // Set "renderedTexture" as our colour attachement #0
        glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, renderedTexture, 0);
        
        // Set the list of draw buffers.
        GLenum DrawBuffers[2] = {GL_COLOR_ATTACHMENT0};
        glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
        
        // Always check that our framebuffer is ok
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"ERROR building framebuffer");
        }*/
        
        glGenTextures(1, &_texture);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 1200, 1000, 0,
                     GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        
        
        
    }
    return self;
}


-(void)renderFrameOfCoreHandovers:(NSArray *) theCoreHandovers forFrameSize:(NSSize)theFrameSize forTimestamp:(double)theTimestamp{
    
    char *framePoiner = malloc(theFrameSize.width * theFrameSize.height * 4);
    
    NSMutableArray *mutableCoreHandovers = [NSMutableArray arrayWithArray:theCoreHandovers];

    for(VSCoreHandover *coreHandover in theCoreHandovers){
        if ([coreHandover isKindOfClass:[VSQuartzComposerHandover class]]) {
            VSFrameCoreHandover *convertedQuartzComposerHandover = [self createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) coreHandover];
            [mutableCoreHandovers replaceObjectAtIndex:[mutableCoreHandovers indexOfObject:coreHandover] withObject:convertedQuartzComposerHandover];
        }
    }
    
    // array with framecoreHandover! and no one else
    
    for (VSCoreHandover *coreHandover in mutableCoreHandovers) {
        
       // NSLog(@"core Handover: %@", coreHandover);
    }
    
    
    
    CGLLockContext([[self openGLContext] CGLContextObj]);
	
	// Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
    
    ////////////
    GLenum status;
    glGenFramebuffersEXT(1, &_frameBuffer);
    // Set up the FBO with one texture attachment
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _frameBuffer);
    glBindTexture(GL_TEXTURE_2D, _texture);

    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D, _texture, 0);
    status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
    if (status != GL_FRAMEBUFFER_COMPLETE_EXT){
        NSLog(@"fbo creation error");
    }
    // Handle error here
    // Your code to draw content to the FBO
    [self renderFrameWithCoreHandovers:nil];


    // ...
    // Make the window the target
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    //Your code to use the contents of the FBO
    // ...
    //Tear down the FBO and texture attachment
    
    //glDeleteTextures(1, &_texture);
    //glDeleteFramebuffersEXT(1, &_frameBuffer);
    ///////////
    
    
    NSLog(@"textureID: %d",_texture);
    
	[[self openGLContext] flushBuffer];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
    
    
    
    
    
    //TODO: Edi to the ma gicdd
    //NSLog(@"epic magic");
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(renderCore:didFinishRenderingFrame:forTimestamp:)]) {
            [self.delegate renderCore:self didFinishRenderingFrame:framePoiner forTimestamp:theTimestamp];
        }
    }
}
- (void)renderFrameWithCoreHandovers:(VSCoreHandover *)theCoreHandovers{
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    g_resources.fade_factor = 0.5;

    
    glUseProgram(g_resources.program);
    
    glUniform1f(g_resources.uniforms.fade_factor, g_resources.fade_factor);
    
    
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, g_resources.textures[0]);
    glUniform1i(g_resources.uniforms.textures[0], 0);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, g_resources.textures[1]);
    glUniform1i(g_resources.uniforms.textures[1], 1);
    
    glBindBuffer(GL_ARRAY_BUFFER, g_resources.vertex_buffer);
    glVertexAttribPointer(g_resources.attributes.position,  /* attribute */
                          2,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*2,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(g_resources.attributes.position);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_resources.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
    glDisableVertexAttribArray(g_resources.attributes.position);
}


- (GLuint)combineTexture:(GLuint) texture with:(GLuint)upperTexture
{	
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    g_resources.fade_factor = 0.5;

    glUseProgram(g_resources.program);
    glUniform1f(g_resources.uniforms.fade_factor, g_resources.fade_factor);
    
    /*
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, g_resources.textures[0]);
    glUniform1i(g_resources.uniforms.textures[0], 0);
*/
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(g_resources.uniforms.textures[0], 0);
 
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, upperTexture);
    glUniform1i(g_resources.uniforms.textures[1], 1);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, g_resources.vertex_buffer);
    glVertexAttribPointer(g_resources.attributes.position,  /* attribute */
                          2,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*2,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(g_resources.attributes.position);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_resources.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
   
    
    glDisableVertexAttribArray(g_resources.attributes.position);
    
  //  adsfölkajsdfölkj
}


#pragma mark- Private Methods

-(VSFrameCoreHandover *) createFrameCoreHandOverFrameQuartzComposerHandover:(VSQuartzComposerHandover *) quartzComposerHandover{
    
    VSFrameCoreHandover *coreHandover = nil;
    
    if (quartzComposerHandover) {
    }
    
    return coreHandover;
}

-(GLuint) getVideoTextureFromNSImage:(NSImage *)inimage{
    CGImageSourceRef imageSource;
    imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)[inimage TIFFRepresentation], NULL);
    CGImageRef image =  CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

    CFRelease(imageSource);
    size_t width  = CGImageGetWidth (image);
    size_t height = CGImageGetHeight(image);
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    
    void *imageData = malloc(width * height * 4);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    CFRelease(colourSpace);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    CGContextDrawImage(ctx, rect, image);
    CGContextRelease(ctx);
    CFRelease(image);
    
    GLuint glName;
    glGenTextures(1, &glName);
    
    glBindTexture(GL_TEXTURE_2D, glName);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
    
    free(imageData);
    return glName;
}

- (GLuint)loadTextureNamed:(NSString *)name
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[[NSBundle bundleWithIdentifier:@"com.visiris.VisirisCore"] URLForImageResource:name], NULL);
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    size_t width  = CGImageGetWidth (image);
    size_t height = CGImageGetHeight(image);
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    
    void *imageData = malloc(width * height * 4);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    CFRelease(colourSpace);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    CGContextDrawImage(ctx, rect, image);
    CGContextRelease(ctx);
    CFRelease(image);
    
    GLuint glName;
    glGenTextures(1, &glName);
    
    glBindTexture(GL_TEXTURE_2D, glName);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
    
    free(imageData);
    return glName;
}

- (NSInteger)make_resources
{
    //create buffer
    g_resources.vertex_buffer = make_buffer(GL_ARRAY_BUFFER,g_vertex_buffer_data,sizeof(g_vertex_buffer_data));
    
    g_resources.element_buffer = make_buffer(GL_ELEMENT_ARRAY_BUFFER,g_element_buffer_data,sizeof(g_element_buffer_data));
    
    //create textures
    g_resources.textures[0] = [self loadTextureNamed:@"jolandabregenz"];
    g_resources.textures[1] = [self loadTextureNamed:@"test"];
    
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



@end
