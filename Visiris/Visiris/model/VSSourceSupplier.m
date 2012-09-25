//
//  VSSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSSourceSupplier.h"

#import "VSParameter.h"
#import "VSAnimation.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"

#import "VSCoreServices.h"



@implementation VSSourceSupplier

@synthesize timelineObject = _timelineObject;

#pragma mark Init

-(id) initWithTimelineObject:(VSTimelineObject *)aTimelineObject{
    if(self = [super init]){
        _timelineObject = aTimelineObject;
    }
    
    return self;
}

- (NSDictionary *)getAtrributesForTimestamp:(double)aTimestamp{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];    
    if(self.timelineObject){
        for(VSParameter *parameter in [self.timelineObject.parameters allValues]){
            if([parameter isKindOfClass:[VSParameter class]]){
                [result setValue:[parameter valueForTimestamp:aTimestamp] forKey:parameter.type];
            }
        }
    }
    
    return result;
    
}


@end
