//
//  VSProjectItemRepresentation.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItemRepresentation.h"

#import "VSCoreServices.h"

@implementation VSProjectItemRepresentation

@synthesize icon = _icon;


#pragma mark - Init

-(id) initWithFile:(NSString *)file ofType:(VSFileType *)type name:(NSString *)name fileSize:(float)fileSize duration:(float)duration itemID:(NSInteger)itemID fileIcon:(NSImage *)icon{
    if(self = [super initWithFile:file ofType:type name:name fileSize:fileSize duration:duration itemID:itemID]){
        self.icon = icon;
    }
    
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self.name = [aDecoder decodeObjectForKey:@"piName"];
    self.filePath = [aDecoder decodeObjectForKey:@"piFilePath"];
    self.duration = [aDecoder decodeFloatForKey:@"piLength"];
    self.fileSize = [aDecoder decodeFloatForKey:@"piFileSize"];
    self.itemID = [aDecoder decodeIntForKey:@"piItemID"];
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"piName"];
    [aCoder encodeObject:self.filePath forKey:@"piFilePath"];
    [aCoder encodeFloat:self.duration forKey:@"piLength"];
    [aCoder encodeFloat:self.fileSize forKey:@"piFileSize"];
    [aCoder encodeInt:self.itemID forKey:@"piItemID"];
}

#pragma mark - Methods

-(NSString*) fileSizeString{
    return [VSFormattingUtils formatedFileSizeStringFromByteValue:self.fileSize];
}

-(NSString*) durationString{
    return [VSFormattingUtils formatedTimeStringFromMilliseconds:self.duration];
}


#pragma mark- NSPasteboardWriting Implementation

-(NSArray*) writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    static NSArray* writeableTypes = nil;
    
    if(!writeableTypes){
        writeableTypes = [NSArray arrayWithObject:VSProjectItemPasteboardType];
    }
    
    return writeableTypes;
}

-(id) pasteboardPropertyListForType:(NSString *)type{
    if([type isEqualToString:VSProjectItemPasteboardType]){
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    return self.name;
}

#pragma mark- NSPasteboardWriting Implementation

+(NSArray*) readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    static NSArray* readableTypes = nil;
    
    if(!readableTypes){
        readableTypes = [NSArray arrayWithObject:VSProjectItemPasteboardType];
    }
    
    return readableTypes;
}

+(NSPasteboardReadingOptions) readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    
    if ([type isEqualToString:VSProjectItemPasteboardType]){
        return NSPasteboardReadingAsKeyedArchive;
    }
    return NSPasteboardReadingAsData; 
}

-(id) initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type{
    
    return nil;
}



@end
