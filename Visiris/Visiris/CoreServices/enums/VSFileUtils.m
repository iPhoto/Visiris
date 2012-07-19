//
//  VSFileUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFileUtils.h"

@implementation VSFileUtils

#pragma mark - Functions

+(float) sizeOfFile:(NSString *)file{
    if(!file || ![[NSFileManager defaultManager] fileExistsAtPath:file])
        return -1;
    
    NSError *error = nil;
    
    double fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:file error:&error] fileSize];
    
    if(!error){
        return fileSize;
    }
    else {
        return -1;
    }
}

+(float) durationInMillisecondsOfFile:(NSString*)file{
    
    if(!file || ![[NSFileManager defaultManager] fileExistsAtPath:file])
        return -1;
    
    id duration = [[self metaDataOfFile:file] objectForKey:(id)kMDItemDurationSeconds];

    if(duration)
        return [duration doubleValue]*1000;
    else {
        return 0;
    }
}

+(NSSize) dimensionsOfFile:(NSString *)file{
    NSSize size = NSMakeSize(0, 0);
    if(file && [[NSFileManager defaultManager] fileExistsAtPath:file]){
        NSDictionary *metaData = [self metaDataOfFile:file];
        size.width = [[metaData valueForKey:(id) kMDItemPixelWidth] intValue];
        size.height = [[metaData valueForKey:(id) kMDItemPixelHeight] intValue];
    }
    
    return size;
}

+(NSString*) colorSpaceOfFile:(NSString *)file{
    NSString* colorSpace;
    if(file && [[NSFileManager defaultManager] fileExistsAtPath:file]){
        NSDictionary *exifData = [self exifDataOfFile:file];
        colorSpace = [exifData valueForKey:(id)kCGImagePropertyExifColorSpace];
    }
    
    return colorSpace;
}

//Todo release CGImageSourceRef
+(NSDictionary*) exifDataOfFile:(NSString*) file{
    NSURL *fileUrl = [NSURL fileURLWithPath:file];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)fileUrl, Nil);
    
    NSDictionary *exifData = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    

    
    return exifData;
}

#pragma mark - Private Functions

//TODO: read out all MetaDAta not only duration and size
/**
 * Reads out the meta data of the given file and returns it as an NSDictionary
 * @param file The file the metaData will be read out /Volumes/Musik/I/Incubus/A Crow Left To The Murder/06 - Sick Sad Little World.mp3of
 * @return NSDictionary holding the metaData of the file
 */
+(NSDictionary*) metaDataOfFile:(NSString*) file{
    
    if(!file || ![[NSFileManager defaultManager] fileExistsAtPath:file])
        return nil;
    
    MDItemRef fileMetaData = MDItemCreate(NULL, (__bridge CFStringRef) file);
    
    if(fileMetaData)
    {
    NSDictionary *metadataDictionary = (__bridge NSDictionary*)MDItemCopyAttributes (fileMetaData, (__bridge CFArrayRef)[NSArray arrayWithObjects:(id)kMDItemDurationSeconds,(id)kMDItemPixelWidth,(id)kMDItemPixelHeight,(id)kCGImagePropertyExifColorSpace,nil]);
    
    return metadataDictionary;
    }
    
    return nil;
}

@end
