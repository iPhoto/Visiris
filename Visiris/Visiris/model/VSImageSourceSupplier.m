//
//  VSImageSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSImageSourceSupplier.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"
#import "VSProjectItem.h"
#import "VisirisCore/VSImage.h"

@implementation VSImageSourceSupplier

-(VSImage *) getFrameForTimestamp:(double)aTimestamp withPlayMode:(VSPlaybackMode)playMode{
    
    if (self.vsImage.data == NULL) {
        
        self.vsImage = [[VSImage alloc] init];
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        CFRelease(imageSource);
        size_t width  = CGImageGetWidth (image);
        size_t height = CGImageGetHeight(image);
        CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
        
        self.vsImage.data = malloc(width * height * 4);
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef ctx = CGBitmapContextCreate(self.vsImage.data, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
        CFRelease(colourSpace);
        //CGContextTranslateCTM(ctx, 0, height);
        //CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextSetBlendMode(ctx, kCGBlendModeCopy);
        CGContextDrawImage(ctx, rect, image);
        CGContextRelease(ctx);
        CFRelease(image);
        
    //    self.vsImage.data = (char *)imageData;
        self.vsImage.size = NSMakeSize(width, height);
        self.vsImage.needsUpdate = YES;
         
    }


    return self.vsImage;
}

@end
