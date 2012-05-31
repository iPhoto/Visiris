//
//  VSSupportedFile.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFileType.h"



@implementation VSFileType
@synthesize name=_name;
@synthesize timelineObjectSourceClassString = _timelineObjectSourceClassString;
@synthesize supplierClassString = _supplierClassString;
@synthesize uti = _uti;
@synthesize fileKind = _fileKind;

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



@end
