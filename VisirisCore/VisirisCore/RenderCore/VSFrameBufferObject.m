//
//  VSFrameBufferObject.m
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameBufferObject.h"
#import <OpenGL/glu.h>

@interface VSFrameBufferObject()

/** The actual Framebuffer Object */
@property (assign) GLuint   buffer;

@end


@implementation VSFrameBufferObject
@synthesize buffer = _buffer;
@synthesize size = _size;
@synthesize texture = _texture;

#pragma mark - Init

- (id)init{
    //size is 16 so it is clearly seeable when this is called, because ist shouldn't be
    return [self initWithSize:NSMakeSize(16, 16)];
}

- (id)initWithSize:(NSSize)size{
    if (self = [super init])
    {
        [self createFBOwithSize:size];
    }
    return self;
}

#pragma mark - Methods

- (void)bind{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, self.buffer);
}

- (void)unbind{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
}

- (void)resize:(NSSize)size{
   // NSLog(@"FBO Resized");
    
    [self delete];
    [self createFBOwithSize:size];
}

- (void)delete{
    glDeleteTextures(1, &_texture);
    glDeleteFramebuffersEXT(1, &_buffer);
}


#pragma mark - Private Methods

/**
 * Creates the FBO on the OpenGL Side
 * @param size Size for of the Texture
 */
- (void)createFBOwithSize:(NSSize)size{
    _size = size;
    
    GLenum status;
    glGenFramebuffersEXT(1, &_buffer);
    // Set up the FBO with one texture attachment
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, self.buffer);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, self.size.width , self.size.height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, self.texture, 0);
    
    status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
    
    if (status != GL_FRAMEBUFFER_COMPLETE_EXT){
        NSLog(@"ERROF: FrameBuffer creation failed - fuck you, because thats why");
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);    
}

@end
