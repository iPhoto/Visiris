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

#pragma mark - Private Functions

//TODO: read out all MetaDAta not only duration and size
/**
 * Reads out the meta data of the given file and returns it as an NSDictionary
 * @param file The file the metaData will be read out of
 * @return NSDictionary holding the metaData of the file
 */
+(NSDictionary*) metaDataOfFile:(NSString*) file{
    
    if(!file || ![[NSFileManager defaultManager] fileExistsAtPath:file])
        return nil;
    
    MDItemRef fileMetaData = MDItemCreate(NULL, (__bridge CFStringRef) file);
    NSDictionary *metadataDictionary = (__bridge NSDictionary*)MDItemCopyAttributes (fileMetaData, (__bridge CFArrayRef)[NSArray arrayWithObjects:(id)kMDItemDurationSeconds,(id)kMDItemPixelWidth,nil]);
    
    return metadataDictionary;
}

@end
