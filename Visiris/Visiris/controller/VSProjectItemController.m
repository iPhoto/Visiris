//
//  VSProjectItemController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItemController.h"
#import "VSProjectItem.h"
#import "VSProjectItemRepresentation.h"
#import "VSFileType.h"

@interface VSProjectItemController()


@end

@implementation VSProjectItemController

@synthesize projectItems    = _projectItems;


#pragma mark- Init

-(id) init{
    if(self = [super init]){
        _projectItems = [[NSMutableArray alloc] initWithCapacity:0];
        [self setTestData];
    }
    
    return self;
}


#pragma mark- Methods


-(BOOL) addNewProjectItemFromFile:(NSString *)filePath{
    return [self addsAndReturnsNewProjectItemFromFile:filePath] != nil;
}

-(VSProjectItem*) addNewProjectForRepresentation:(VSProjectItemRepresentation*) projectItemRepresentation{
    VSProjectItem *newItem = [self projectItemForFile:projectItemRepresentation.filePath];
    
    if(!newItem){
        newItem = [[VSProjectItem alloc] initWithFile:projectItemRepresentation.filePath
                                                          ofType:projectItemRepresentation.fileType
                                                            name:projectItemRepresentation.name
                                                        fileSize:projectItemRepresentation.fileSize
                                                        duration:projectItemRepresentation.duration
                                                          itemID:projectItemRepresentation.itemID];
    
    [self.projectItems addObject:newItem];
    }
    
    return newItem;
}

-(VSProjectItem*)addsAndReturnsNewProjectItemFromFile:(NSString *)filePath{
    
    VSProjectItem *newItem = [self projectItemForFile:filePath];
    
    if(newItem)
        return newItem;
    
    newItem = [self createNewProjectItemFromFile:filePath];
    
    if(newItem){
        //adds the new projectItem to the controllers list of items
        [self.projectItems addObject:newItem];
        
        return newItem;
    }
    else {
        return nil;
    }
}

-(VSProjectItem*) createNewProjectItemFromFile:(NSString *)filePath{
    
    VSProjectItem *newItem = [self projectItemForFile:filePath];
    
    if(!newItem)
    {
    
    //leaves the function and returns NO if the filePath is nil, th file doesn't exist or the file is not supported.
    if(!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath] || ![self isFileSupported:filePath])
        return nil;
    
    newItem = [self projectItemForFile:filePath];
    
    if(newItem)
        return newItem;
    
    //by default the name of the projectItme is the name of file without its extension.
    NSString* name = [[filePath lastPathComponent] stringByDeletingPathExtension];
    
    //size of the files in bytes
    float fileSize = [VSFileUtils sizeOfFile:filePath];
    
    //type of the file as VsFileType
    VSFileType *type = [VSSupportedFilesManager typeOFile:filePath];
    
    //if the file doesn't have an duration itself the default duration is set for this item
    float duration = VSDefaultProjectItemDuration;
    if(type.fileKind == VSFileKindVideo || type.fileKind == VSFileKindAudio){
        duration = [VSFileUtils durationInMillisecondsOfFile:filePath];
    }
    
    newItem = [[VSProjectItem alloc] initWithFile:filePath
                                           ofType:type
                                             name:name
                                         fileSize:fileSize
                                         duration:duration
                                           itemID:[self getNewProjectItemID]];
    }
    
    return newItem;
    
}


//TODO: faster search
-(VSProjectItem*) projectItemWithID:(NSInteger)id{
    for(VSProjectItem* item in self.projectItems){
        if(item.itemID == id)
            return item;
    }
    
    return nil;
}


#pragma mark- Private Methods

/**
 Fills the projectItem with testData
 */
-(void) setTestData{
    
    NSString *relativeTestDataPath = @"~/Desktop/visiris-testfiles/";
    
    NSString *fullPath = [relativeTestDataPath stringByExpandingTildeInPath];
    
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:nil];
    
    
    for(NSString* s  in files){
            [self addNewProjectItemFromFile:[NSString stringWithFormat:@"%@/%@",fullPath,s]];
    }
}

//TODO: create better ids
/**
 * Returns a unique ID for a project item
 *
 * Returns the count of the selfProjectItems + 1
 * @return New unique ID for a project item
 */
-(NSInteger) getNewProjectItemID{
    return [self.projectItems count] + 1;
}

/**
 * Checks if the given file is supported by Visirs.
 * 
 * Asks the VSSupportedFilesManager if the given file is support
 * @param file File that will be checked if it is supported
 * @return YES if the file is supported, NO otherwise
 */
-(BOOL) isFileSupported:(NSString*) file{
    return [VSSupportedFilesManager supportsFile:file];
}

/**
 * Looks for a VSProjectItem in the projectItems Array representing the given file.
 * @param file File path a VSProjectItem is looked up for
 * @return The VSProjectItem representing the file if it is found, nil otherwise
 */
-(VSProjectItem*) projectItemForFile:(NSString*) file{
    for(VSProjectItem *item in self.projectItems){
        if ([item.filePath isEqualToString:file]) {
            return item;
        }
    }
    return nil;
}


#pragma mark- Properties

/* Stores all ProjectItmes the controller is responsible for */
-(NSMutableArray*) projectItems{
    return [self mutableArrayValueForKey:@"projectItems"];
}



@end
