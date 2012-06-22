//
//  VSSupportedFilesManager.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSSupportedFilesManager.h"
#import "VSFileType.h"
#import "VSVideoSource.h"
#import "VSImageSource.h"
#import "VSQuartzComposerSource.h"
#import "VSAudioSource.h"
#import "VSVideoSourceSupplier.h"
#import "VSImageSourceSupplier.h"
#import "VSQuartzComposerSourceSupplier.h"
#import "VSAudioSourceSupplier.h"
#import "VSCoreServices.h"

@class VSVideoSourceSupplier;
@class VSImageSourceSupplier;
@class VSQuartzComposerSourceSupplier;
@class VSAudioSourceSupplier;

@implementation VSSupportedFilesManager

static NSMutableDictionary* supportedFiles;

static NSString* videoClassString;
static NSString* imageClassString;
static NSString* audioClassString;
static NSString* quartzComposerClassString;

static NSString* videoSupplierClassString;
static NSString* imageSupplierClassString;
static NSString* audioSupplierClassString;
static NSString* quartzComposerSupplierClassString;

#pragma mark - Init 

+(void) initialize{
    
    [self setClassStrings];
    [self setSupplierClassStrings];
    
    supportedFiles = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    /* Creates an list entry for every support file type.*/
    [self addSupportedAudio:@"public.mp3" name:@"MP3"];
    [self addSupportedVideo:@"com.apple.quicktime-movie" name:@"MOV"];
    [self addSupportedImage:@"public.png" name:@"PNG"];
    [self addSupportedImage:@"public.jpeg" name:@"JPEG"];
    [self addSupportedVideo:@"public.mpeg-4" name:@"MP4"];
    [self addSupportedQuartzComposer:@"com.apple.quartz-​composer-composition" name:@"QTZ"];
}

#pragma mark- Functions

+(NSDictionary*) supportedFiles{
    return supportedFiles;
}

+(BOOL) supportsFile:(NSString*) file{
    if([self typeOFile:file]){
        return YES;
    }
    else {
        return NO;
    }
}

+(VSFileType*) typeOFile:(NSString*)file{
    NSString* fileType = [[NSWorkspace sharedWorkspace] typeOfFile:file error:nil];
    return [supportedFiles objectForKey:fileType];
    
}

#pragma mark- Private Functions

/** 
 Sets the classStrings for the different VSFileKinds.
 */
+(void) setClassStrings{
    videoClassString = NSStringFromClass([VSVideoSource class]);
    imageClassString = NSStringFromClass([VSImageSource class]);
    audioClassString = NSStringFromClass([VSAudioSource class]);
    quartzComposerClassString = NSStringFromClass([VSQuartzComposerSource class]);
}

/** 
 Sets the supplierClassStrings for the different VSFileKinds.
 */
+(void) setSupplierClassStrings{
    videoSupplierClassString = NSStringFromClass([VSVideoSourceSupplier class]);
    imageSupplierClassString = NSStringFromClass([VSImageSourceSupplier class]);
    audioSupplierClassString = NSStringFromClass([VSAudioSourceSupplier class]);
    quartzComposerSupplierClassString = NSStringFromClass([VSQuartzComposerSourceSupplier class]);
}

/**
 Adds a new VSFileType ofKind Video
 @param fileType UTI of the file type
 @param fileType Uniform Type Identifier of the file type.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 */ 
+(void) addSupportedVideo: (NSString*) fileType name:(NSString*)name{
    [self addSupportedFile:fileType  name:name ofKind:VSFileKindVideo classString:videoClassString supplierClassString:videoSupplierClassString];
}

/**
 Adds a new VSFileType ofKind Image
 @param fileType UTI of the file type
 @param fileType Uniform Type Identifier of the file type.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 */ 
+(void) addSupportedImage: (NSString*) fileType name:(NSString*)name{
    [self addSupportedFile:fileType name:name ofKind:VSFileKindImage classString:imageClassString supplierClassString:imageSupplierClassString];
}

/**
 Adds a new VSFileType ofKind QuartzComposer
 @param fileType UTI of the file type
 @param fileType Uniform Type Identifier of the file type.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 */ 
+(void) addSupportedQuartzComposer: (NSString*) fileType name:(NSString*)name{
    [self addSupportedFile:fileType name:name ofKind:VSFileKindQuartzComposerPatch classString:quartzComposerClassString supplierClassString:quartzComposerSupplierClassString];
}

/**
 Adds a new VSFileType ofKind Audio
 @param fileType UTI of the file type
 @param fileType Uniform Type Identifier of the file type.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 */ 
+(void) addSupportedAudio: (NSString*) fileType name:(NSString*)name{
    [self addSupportedFile:fileType name:name ofKind:VSFileKindAudio classString:audioClassString supplierClassString:audioSupplierClassString];
}

/**
 Adds a new supported file.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 @param uti Uniform Type Identifier of the file type.
 @param kind Kind of the file like stored in the VSFileKind-Enum. E.g.: IMAGE, MOVIE, AUDIO, QUARTZ-COMPOSER. According to the fileKind the classString is set.
 @param classString Name of the child-class of VSTimelineObejctSource associated with that fileType. The class is usually depending on the the fileKind.
 @param supplierClassString Name of the child-class of VSSourceSupplier associated with that fileType. The class is usually depending on the the fileKind
 */
+(void) addSupportedFile: (NSString*) uti name:(NSString*) name ofKind:(VSFileKind) kind  classString:(NSString*) classString supplierClassString:(NSString*) supplierClassString{
    [supportedFiles setObject:[[VSFileType alloc] initWithName:name uti:uti ofKind:kind timelineObjectSourceClassString:classString supplierClassString:supplierClassString ] forKey:uti];
}

@end
