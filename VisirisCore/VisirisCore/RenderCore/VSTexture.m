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

@implementation VSTexture
@synthesize texture = _texture;
@synthesize size = _size;
/*
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
 */

-(id)initEmptyTextureWithSize:(NSSize) size{
    if(self = [super init]){
        _size = size;
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

-(id)initWithNSImage:(NSImage *)theImage{
    if (self = [super init]) {
        int samplesPerPixel = 0;
        
        _size = [theImage size];
        
        [theImage lockFocus];
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, _size.width, _size.height)];
        [theImage unlockFocus];
                
        // Generate a new texture name if one was not provided.
        if (self.texture == 0)
              glGenTextures (1, &_texture);
          
        glBindTexture (GL_TEXTURE_2D, self.texture);
        
        // Set proper unpacking row length for bitmap.
        glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
        
        // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
        glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
        
        // Non-mipmap filtering (redundant for texture_rectangle).
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        samplesPerPixel = [bitmap samplesPerPixel];
        
        // Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
        if(![bitmap isPlanar] && (samplesPerPixel == 3 || samplesPerPixel == 4)) {
            
            glTexImage2D(GL_TEXTURE_2D, 0,
                         samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                         [bitmap pixelsWide],
                         [bitmap pixelsHigh],
                         0,
                         samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                         GL_UNSIGNED_INT_8_8_8_8_REV,
                         [bitmap bitmapData]);

        } else {
            // Handle other bitmap formats.
        }
    }
    return self;
}

- (void)replaceContent:(NSImage *) theImage{
    int samplesPerPixel = 0;    
    _size = [theImage size];
    
    [theImage lockFocus];
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, _size.width, _size.height)];
    [theImage unlockFocus];
    
    // Generate a new texture name if one was not provided.
    if (self.texture == 0)
        NSLog(@"ERRORRR");
    
    glBindTexture (GL_TEXTURE_2D, self.texture);
    
    // Set proper unpacking row length for bitmap.
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
    
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
 
    samplesPerPixel = [bitmap samplesPerPixel];
    
    // Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
    if(![bitmap isPlanar] && (samplesPerPixel == 3 || samplesPerPixel == 4)) {
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, self.size.width, self.size.height, samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8, GL_UNSIGNED_INT_8_8_8_8_REV, [bitmap bitmapData]);
        
       /* glTexImage2D(GL_TEXTURE_2D, 0,
                     samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                     [bitmap pixelsWide],
                     [bitmap pixelsHigh],
                     0,
                     samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                     GL_UNSIGNED_INT_8_8_8_8_REV,
                     [bitmap bitmapData]);*/
        
    } else {
        NSLog(@"Shit happens");
        // Handle other bitmap formats.
    }
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
