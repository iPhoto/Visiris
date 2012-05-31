//
//  VSKeyFrame.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSKeyFrame.h"

@implementation VSKeyFrame
@synthesize value = _value;
@synthesize timestamp = _timestamp;

#pragma mark - Init

-(id) initWithValue:(id)aValue forTimestamp:(double)aTimestamp{
    if(self = [self init]){
        self.value = aValue;
        self.timestamp = aTimestamp;
    }
    
    return self;
}


@end
