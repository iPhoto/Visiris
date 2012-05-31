//
//  VSTimelineObjectSource.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectSource.h"

#import "VSProjectItem.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectSource

@synthesize projectItem=_projectItem;
@synthesize parameters=_parameters;


#pragma mark - Functions

+(NSString *) parameterDefinitionXMLFileName{
    return nil;
}

#pragma mark - Methods

-(NSString *) filePath{
    return self.projectItem.filePath;
}

-(double) fileDuration{
    return self.projectItem.duration;
}

-(float) fileSize{
    return self.projectItem.fileSize;
}


#pragma mark - NSCopying Implementation

//TODO: Copy With Zone how to?
-(id) copyWithZone:(NSZone *)zone{
    VSTimelineObjectSource *copy = [[VSTimelineObjectSource allocWithZone:zone] init];
    copy.projectItem = self.projectItem;
    copy.parameters  = [[NSDictionary alloc] initWithDictionary:self.parameters copyItems:YES];
    
    return copy;
}

@end
