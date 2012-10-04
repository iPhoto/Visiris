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

@end
