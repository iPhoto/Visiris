//
//  VSTimelineObjectSource.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectSource.h"

#import "VSProjectItem.h"
#import "VSParameter.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectSource

@synthesize projectItem=_projectItem;
@synthesize parameters=_parameters;

-(id) initWithProjectItem:(VSProjectItem*) aProjectItem andParameters:(NSDictionary*) parameters{
    if(self = [super init]){
        self.projectItem = aProjectItem;
        self.parameters  = [[NSDictionary alloc] initWithDictionary:parameters copyItems:YES];
    }
    
    return self;
}

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

-(NSArray *) visibleParameters{
    NSSet *set = [self.parameters keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[VSParameter class]]){
            if(!((VSParameter*) obj).hidden){
                return YES;
            }
        }
        return NO;
    }];
    
    NSString *notFoundMarker = @"not found";
    
    NSArray *tmpArray = [self.parameters objectsForKeys:[set allObjects] notFoundMarker:notFoundMarker];
    tmpArray = [tmpArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:YES]]];
    
    return tmpArray;
}


@end
