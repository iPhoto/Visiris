//
//  VSTexture.m
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTexture.h"
#import <OpenGL/glu.h>
#import "VSImageContext.h"
#import "VSImage.h"

@implementation VSTexture
@synthesize texture = _texture;
@synthesize size = _size;
@synthesize timeLineObjectId = _timeLineObjectId;
@synthesize trackId = _trackId;

-(id)initEmptyTextureWithSize:(NSSize) size trackId:(NSInteger) trackId{
    if(self = [super init]){
        _timeLineObjectId = -1;
        _size = size;
        _trackId = trackId;
        
        void *imageData = malloc(_size.width * _size.height * 4);
        
        glGenTextures(1, &_texture);
        glBindTexture(GL_TEXTURE_2D, self.texture);
        
        glPixelStorei(GL_UNPACK_ROW_LENGTH, size.width);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, _size.width, _size.height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
        
        free(imageData);
    }
    return  self;
}

- (void)replaceContent:(VSImage *)theImage timeLineObjectId:(NSInteger) timeLineObjectId{
    if (self.timeLineObjectId != timeLineObjectId ||
        theImage.needsUpdate ) {
        [self bind];
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, self.size.width, self.size.height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, theImage.data);
        _timeLineObjectId = timeLineObjectId;
        theImage.needsUpdate = NO;
    }
}

-(void)bind{
    glBindTexture(GL_TEXTURE_2D, self.texture);
}

-(void)unbind{
    glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)deleteTexture{
    glDeleteTextures(1, &_texture);
}



@end
