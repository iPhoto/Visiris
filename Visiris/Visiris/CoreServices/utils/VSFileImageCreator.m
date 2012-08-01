//
//  VSFileImageCreator.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuickLook/QuickLook.h>

#import "VSFileImageCreator.h"
#import "VSCoreServices.h"

@implementation VSFileImageCreator

#pragma mark- Functions

+(NSImage *)createIconForProjectItem:(NSString *)file{
    return [self createImageForFile:file withWidht:VSProjectItemIconWidth withHeight:VSProjectItemIconHeight];
}

+(NSImage *)createIconForTimelineObject:(NSString *)file{
    return [self createImageForFile:file withWidht:VSTimelineObejctIconWidth withHeight:VSTimelineObjectIconHeight];
}


+(NSImage*) createImageForFile:(NSString *)file withWidht:(NSInteger)width withHeight:(NSInteger)height{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:file];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey: (NSString*)kQLThumbnailOptionIconModeKey];
    
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorSystemDefault, (__bridge CFURLRef) url, CGSizeMake(width, height), (__bridge CFDictionaryRef) options);
    
    NSImage *resultImage = [[NSImage alloc] initWithCGImage:ref size:NSMakeSize(width, height)];
    CGImageRelease(ref);
    
    return resultImage;
}
@end
