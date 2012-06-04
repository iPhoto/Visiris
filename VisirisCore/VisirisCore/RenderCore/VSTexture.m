//
//  VSTexture.m
//  VisirisCore
//
//  Created by Scrat on 31/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTexture.h"
#import <OpenGL/glu.h>

@implementation VSTexture
@synthesize texture = _texture;

//Fixme: die beiden inits machen fast das selbe
-(id)initWithNSImage:(NSImage *)theImage{
    if (self = [super init]) {
        CGImageSourceRef imageSource;
        imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)[theImage TIFFRepresentation], NULL);
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
        
        glGenTextures(1, &_texture);
        
        glBindTexture(GL_TEXTURE_2D, self.texture);
        
        glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
        
        free(imageData);
    }
    return self;
}

-(id)initWithName:(NSString *)name{
    if(self = [super init]){
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
        
        glGenTextures(1, &_texture);
        
        glBindTexture(GL_TEXTURE_2D, self.texture);
        
        glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
        
        free(imageData);
    }
    return  self;
}

-(void)bind{
    glBindTexture(GL_TEXTURE_2D, self.texture);
}

-(void)unbind{
    glBindTexture(GL_TEXTURE_2D, self.texture);
}

-(void)deleteTexture{
    glDeleteTextures(1, &_texture);
}



@end
