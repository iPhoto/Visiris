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

- (id)initWithNSImage:(NSImage *) inimage WithSize: (NSSize)size
{
    if(self = [super init]){

	size.width = floorf( size.width );
	size.height = floorf( size.height );
	
	//GLuint tex;
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] 
                                  initWithBitmapDataPlanes: NULL
                                  pixelsWide: size.width
                                  pixelsHigh: size.height
                                  bitsPerSample: 8
                                  samplesPerPixel: 4
                                  hasAlpha: YES
                                  isPlanar: NO
                                  colorSpaceName: NSDeviceRGBColorSpace
                                  bitmapFormat: 0
                                  bytesPerRow: 0
                                  bitsPerPixel: 32];
	bzero( [imageRep bitmapData], size.height * [imageRep bytesPerRow] );
	
	NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: imageRep];
	NSGraphicsContext *old = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext: ctx];
	
	NSRect fromRect = { NSZeroPoint, [inimage size] };
	NSRect toRect = { NSZeroPoint, size };
	[inimage drawInRect: toRect fromRect: fromRect operation: NSCompositeSourceOver fraction: 1.0];
	
	[NSGraphicsContext setCurrentContext: old];
	
	// create the texture
	glGenTextures(1, &_texture);
	
	glBindTexture( GL_TEXTURE_RECTANGLE_EXT, self.texture);
//	CheckGLError( "glBindTexture" );
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP );
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP );
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
//	CheckGLError( "glTexParameteri" );
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
	glPixelStorei( GL_UNPACK_ROW_LENGTH, [imageRep bytesPerRow] / 4 );
//	CheckGLError( "glPixelStorei" );
	glTexImage2D( GL_TEXTURE_RECTANGLE_EXT, 
                 0, 
                 GL_RGBA, 
                 size.width, 
                 size.height, 
                 0, 
                 GL_RGBA, 
                 GL_UNSIGNED_BYTE, 
                 [imageRep bitmapData] );
    
//	CheckGLError("glTexImage2D");
	
	//[imageRep release];
	
//	return tex;
    }
    return  self;
}

//ANDI STUFF
/*-(id)initWithNSImage:(NSImage *)theImage{
    if (self = [super init]) {
                
        
        int samplesPerPixel = 0;
        NSSize imgSize = [theImage size];
        
        [theImage lockFocus];
        NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
        [theImage unlockFocus];
        
        // Set proper unpacking row length for bitmap.
        glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
        
        // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
        glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
        
        // Generate a new texture name if one was not provided.
        if (self.texture == 0)
        {
              glGenTextures (1, &_texture);
        }
          
        glBindTexture (GL_TEXTURE_RECTANGLE_EXT, self.texture);
        
        // Non-mipmap filtering (redundant for texture_rectangle).
        glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
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
        
        
//        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)[theImage TIFFRepresentation], NULL);
//        CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
//        
//        
//        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
//        CFDataRef data = CGDataProviderCopyData(dataProvider);
//        const unsigned char * buffer =  CFDataGetBytePtr(data);
//        
//        
//        size_t width  = theImage.size.width;
//        size_t height = theImage.size.height;
//
//        
//        glGenTextures(1, &_texture);
//        
//        glBindTexture(GL_TEXTURE_2D, self.texture);
//        
//        glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)width);
//        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, (int)width, (int)height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, (GLvoid *)buffer);
//        
//        CFRelease(imageSource);
    }
    return self;
}*/

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
