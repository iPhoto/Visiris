//
//  VSTransformTexture.m
//  VisirisCore
//
//  Created by Scrat on 17/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTransformTextureManager.h"
#import "VSTransformShader.h"
#import <OpenGL/glu.h>
#import "VSFrameBufferObject.h"
#import "VSParameterTypes.h"


@interface VSTransformTextureManager()

/** The Transformshader */
@property (strong) VSTransformShader    *shader;

/** Stores the vertices for the plane */
@property (assign) GLuint               vertex_buffer;

/** The order of the vertices */
@property (assign) GLuint               element_buffer;

/** OpenGLContext */
@property (weak) NSOpenGLContext        *glContext;

/** The Dictionary contains one FBO for each Track */
@property (strong) NSMutableDictionary  *fboForTrack;

@end


@implementation VSTransformTextureManager
@synthesize shader              = _shader;
@synthesize vertex_buffer       = _vertex_buffer;
@synthesize element_buffer      = _element_buffer;
@synthesize glContext           = _glContext;
@synthesize fboForTrack         = _fboForTrack;


#pragma Mark - Init

- (id)initWithContext:(NSOpenGLContext *)context{
    if (self = [super init]) {
        self.shader = [[VSTransformShader alloc] init];
        self.fboForTrack = [[NSMutableDictionary alloc] init];
        
        [self make_resources];
     //   [self createFBOWithSize:NSMakeSize(800.0f, 600.0f) trackId:1];
   //     VSFrameBufferObject *fbo = [[VSFrameBufferObject alloc] initWithSize:NSMakeSize(800.0f, 600.0f)];
    //    [self.fboForTrack setObject:fbo forKey:[NSNumber numberWithInteger:1]];

    }
    return self;
}

#pragma mark - Methods

- (GLuint)transformTexture:(GLuint)texture atTrack:(NSInteger)trackId withAttributes:(NSDictionary *)attributes withTextureSize:(NSSize)textureSize forOutputSize:(NSSize)outputSize isQCPatch:(BOOL)qcPatch{
    
    //NSLog(@"texturesize: %@",NSStringFromSize(textureSize) );    
    //NSLog(@"outputsize: %@",NSStringFromSize(outputSize) );    
    //NSLog(@"%@",attributes );    
    
    VSFrameBufferObject *fbo = [self getFboForTrackId:trackId];

    [fbo bind];
    
    glViewport(0, 0, fbo.size.width,fbo.size.height);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shader.program);
    
    
    glUniform1f(self.shader.uniformObjectWidth, textureSize.width); 
    glUniform1f(self.shader.uniformObjectHeight, textureSize.height);
    glUniform1f(self.shader.uniformWindowWidth, outputSize.width);
    glUniform1f(self.shader.uniformWindowHeight, outputSize.height);
    glUniform1f(self.shader.uniformScaleX, [[attributes valueForKey:VSParameterKeyScaleWidth] floatValue]);
    glUniform1f(self.shader.uniformScaleY, [[attributes valueForKey:VSParameterKeyScaleHeight] floatValue]);
    glUniform1f(self.shader.uniformRotateX, [[attributes valueForKey:VSParameterKeyRotationX] floatValue]);
    glUniform1f(self.shader.uniformRotateY, [[attributes valueForKey:VSParameterKeyRotationY] floatValue]);
    glUniform1f(self.shader.uniformRotateZ, [[attributes valueForKey:VSParameterKeyRotationZ] floatValue]);
    glUniform1f(self.shader.uniformTranslateX, [[attributes valueForKey:VSParameterKeyPositionX] floatValue]);
    glUniform1f(self.shader.uniformTranslateY, [[attributes valueForKey:VSParameterKeyPositionY] floatValue]);
    glUniform1f(self.shader.uniformTranslateZ, [[attributes valueForKey:VSParameterKeyPositionZ] floatValue]);
    glUniform1f(self.shader.uniformIsQCPatch, qcPatch);

    
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(self.shader.uniformTexture, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertex_buffer);
    glVertexAttribPointer(self.shader.attributePosition,  /* attribute */
                          4,                                /* size */
                          GL_FLOAT,                         /* type */
                          GL_FALSE,                         /* normalized? */
                          sizeof(GLfloat)*4,                /* stride */
                          (void*)0                          /* array buffer offset */
                          );
    glEnableVertexAttribArray(self.shader.attributePosition);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.element_buffer);
    glDrawElements(GL_TRIANGLE_STRIP,  /* mode */
                   4,                  /* count */
                   GL_UNSIGNED_SHORT,  /* type */
                   (void*)0            /* element array buffer offset */
                   );
    
    glDisableVertexAttribArray(self.shader.attributePosition);
    
    [fbo unbind];
    [[self glContext] flushBuffer];
    
    return fbo.texture;
}

- (void)createFBOWithSize:(NSSize)size trackId:(NSInteger) trackId{
    
    if ([self.fboForTrack objectForKey:[NSNumber numberWithInteger:trackId]]) {
        return;
    }
    
    VSFrameBufferObject *fbo = [[VSFrameBufferObject alloc] initWithSize:size];
    [self.fboForTrack setObject:fbo forKey:[NSNumber numberWithInteger:trackId]];
     
}

- (void)resizeOutputSize:(NSSize)size{
    for (id track in self.fboForTrack) {
        VSFrameBufferObject *tempFBO = [self.fboForTrack objectForKey:track];
        [tempFBO resize:size];
    }
}

- (void)deleteFBOforTrackID:(NSInteger)trackID{
    
    VSFrameBufferObject *temp = [self.fboForTrack objectForKey:[NSNumber numberWithInteger:trackID]];
    [temp delete];
    [self.fboForTrack removeObjectForKey:[NSNumber numberWithInteger:trackID]];
}

#pragma mark - Private Methods

/**
 * Basic Buffercreation for the plane
 */
- (void)make_resources{
    GLfloat g_vertex_buffer_data[] = { 
        -1.0f, -1.0f, 0.0f, 1.0f,
        1.0f, -1.0f, 0.0f, 1.0f,
        -1.0f,  1.0f, 0.0f, 1.0f,
        1.0f,  1.0f, 0.0f, 1.0f
    };
    
    GLushort g_element_buffer_data[] = { 0, 1, 2, 3 };
    
    self.vertex_buffer = [self make_buffer:GL_ARRAY_BUFFER withData:g_vertex_buffer_data withSize:sizeof(g_vertex_buffer_data)];
    self.element_buffer = [self make_buffer:GL_ELEMENT_ARRAY_BUFFER withData:g_element_buffer_data withSize:sizeof(g_element_buffer_data)];
}

/**
 * Helper Method for creating a buffer
 * @param target Type of Buffer
 * @param buffer_data The Plain Buffer Data
 * @param buffer_size Size of the Buffer. Can be found out using sizeof()
 * @return ID of the Buffer in the current active Context
 */
- (GLuint) make_buffer:(GLenum) target withData:(const void *)buffer_data withSize:(GLsizei)buffer_size{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(target, buffer);
    glBufferData(target, buffer_size, buffer_data, GL_STATIC_DRAW);
    return buffer;
}

/**
 * Each Track is associated with one FBO
 * @param track The ID of the Track
 * @return The FBO which corresponds to the trackID
 */
- (VSFrameBufferObject *)getFboForTrackId:(NSInteger) track{
    return [self.fboForTrack objectForKey:[NSNumber numberWithInteger:track]];
}

@end
