//
//  VSSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSSourceSupplier.h"

#import "VSParameterTypes.h"
#import "VSParameter.h"
#import "VSAnimation.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"



@implementation VSSourceSupplier

@synthesize timelineObject = _timelineObject;

#pragma mark Init

-(id) initWithTimelineObject:(VSTimelineObject *)aTimelineObject{
    if(self = [super init]){
        _timelineObject = aTimelineObject;
    }
    
    return self;
}


//TODO: returns only the defaultValueForNow
- (NSDictionary *)getAtrributesForTimestamp:(double)aTimestamp{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    if(self.timelineObject){
        for(VSParameter *parameter in [self.timelineObject.parameters allValues]){
            [result setValue:parameter.animation.defaultValue forKey:parameter.type];
        }
    }
    
    return result;
    
}


@end
