//
//  VSCoreHandover.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSCoreHandover.h"

@implementation VSCoreHandover
@synthesize timestamp = _timestamp;
@synthesize attributes = _attributes;

#pragma mark - Init

-(id) initWithAttributes:(NSDictionary *) theAttributes forTimestamp:(double) theTimestamp{
    if(self = [super init]){
        self.timestamp = theTimestamp;
        self.attributes = theAttributes;
    }
    
    return self;
}



@end
