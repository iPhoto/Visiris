//
//  VSVideoSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSVideoSourceSupplier.h"
#import "AVFoundation/AVFoundation.h"
#import "VisirisCore/VSImage.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"
#import "VSProjectItem.h"


@implementation VSVideoSourceSupplier

-(VSImage *) getFrameForTimestamp:(double)aTimestamp{
    
    
   
    
    NSLog(@"timestamp: %@", [NSNumber numberWithDouble:aTimestamp]);
    
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 

    AVAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime timePoint = CMTimeMakeWithSeconds(aTimestamp, 600);  

    CMTime actualTime;
    NSError *error = nil;
    
    CGImageRef image = [imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];

    if (image != NULL) {
        NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
        NSString *requestedTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, timePoint);
        
        NSLog(@"got image: Asked for %@, got %@", requestedTimeString, actualTimeString);
        
        
        if (self.vsImage == nil) {
            self.vsImage = [[VSImage alloc] init];
        }
        
        // Do something interesting with the image.
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
        
        self.vsImage.data = (char *)imageData;
        self.vsImage.size = NSMakeSize(width, height);

        //
        
        //CGImageRelease(image);
    }
    
    return self.vsImage;
    
    /*if (self.vsImage == nil) {
        self.vsImage = [[VSImage alloc] init];
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:self.timelineObject.sourceObject.projectItem.filePath]; 
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
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
        
        self.vsImage.data = (char *)imageData;
        self.vsImage.size = NSMakeSize(width, height);
    }*/
}

/*- (NSImage *)imageFromVideoURL:(NSURL *)videoUrl {
    
    // result
    NSImage *image = nil;
    
    // AVAssetImageGenerator
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calc midpoint time of video
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    
    // get the image from
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL) {
        // cgimage to uiimage
        image = [[NSImage alloc] initWithCGImage:halfWayImage];
        CGImageRelease(halfWayImage);
    }
    
    // release
    [imageGenerator release];
    [asset release];
    
    // return
    return [image autorelease];
    
}*/

@end
