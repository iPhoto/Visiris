//
//  VSProjectItem.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItem.h"
#import "VSCoreServices.h"

@implementation VSProjectItem

#define kName @"Name"
#define kFilePath @"FilePath"
#define kDuration @"Duration"
#define kFileSize @"FileSize"
#define kItemID @"ItemID"
#define kFileType @"FileType"

-(id) initWithFile:(NSString *)file ofType:(VSFileType*) type name:(NSString *)name fileSize:(float)fileSize duration:(float)duration itemID:(NSInteger)itemID{
    if(self = [super init]){
        self.filePath = file;
        self.name = name;
        self.fileSize = fileSize;
        self.duration = duration;
        self.itemID = itemID;
        self.fileType = type;
    }
    
    return self;
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeObject:self.filePath forKey:kFilePath];
    [aCoder encodeObject:self.fileType forKey:kFileType];
    [aCoder encodeDouble:self.duration forKey:kDuration];
    [aCoder encodeDouble:self.fileSize forKey:kFileSize];
    [aCoder encodeInteger:self.itemID forKey:kItemID];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [self init]) {
        self.name = [aDecoder decodeObjectForKey:kName];
        self.filePath = [aDecoder decodeObjectForKey:kFilePath];
        self.fileType = [aDecoder decodeObjectForKey:kFileType];
        self.duration = [aDecoder decodeDoubleForKey:kDuration];
        self.fileSize = [aDecoder decodeDoubleForKey:kFileSize];
        self.itemID = [aDecoder decodeIntegerForKey:kItemID];
    }
    
    return self;
}

@end
