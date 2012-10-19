//
//  VSSupportedFile.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFileType.h"



@implementation VSFileType

#define kName @"Name"
#define kUTI @"UTI"
#define kSourceClassString @"TimelineObjectSourceClassString"
#define kSupplierClassString @"SupplierClassString"
#define kFileKind @"FileKind"


-(id)initWithName:(NSString *)name uti:(NSString *)uti ofKind:(VSFileKind) kind timelineObjectSourceClassString:(NSString *)timelineObjectSourceClassString supplierClassString:(NSString *)supplierClassString{
    if(self = [super init]){
        self.name = name;
        self.timelineObjectSourceClassString = timelineObjectSourceClassString;
        self.uti = uti;
        self.fileKind = kind;
        self.supplierClassString = supplierClassString;
    }
    
    return self;
}

#pragma mark -  NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeObject:self.uti forKey:kUTI];
    [aCoder encodeObject:self.supplierClassString forKey:kSupplierClassString];
    [aCoder encodeObject:self.timelineObjectSourceClassString forKey:kSourceClassString];
    [aCoder encodeInteger:self.fileKind forKey:kFileKind];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if( self = [self init]){
        self.name = [aDecoder decodeObjectForKey:kName];
        self.uti = [aDecoder decodeObjectForKey:kUTI];
        self.supplierClassString = [aDecoder decodeObjectForKey:kSupplierClassString];
        self.timelineObjectSourceClassString = [aDecoder decodeObjectForKey:kSourceClassString];
        self.fileKind = [aDecoder decodeIntegerForKey:kFileKind];
    }
    
    return self;
}


@end
