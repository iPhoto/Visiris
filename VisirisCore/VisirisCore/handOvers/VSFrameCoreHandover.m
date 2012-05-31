//
//  VSFrameCoreHandover.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameCoreHandover.h"

@implementation VSFrameCoreHandover
@synthesize frame = _frame;

-(id) initWithFrame:(NSImage*) inFrame andAttributes:(NSDictionary *) theAttributes forTimestamp:(double)theTimestamp{
    if(self = [super initWithAttributes:theAttributes forTimestamp:theTimestamp]){
        self.frame = inFrame;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"frame: %@", self.frame];
}

@end
