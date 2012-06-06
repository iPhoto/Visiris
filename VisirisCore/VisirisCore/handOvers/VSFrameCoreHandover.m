//
//  VSFrameCoreHandover.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameCoreHandover.h"

@implementation VSFrameCoreHandover

@synthesize frame       = _frame;
@synthesize textureID   = _textureID;

-(id) initWithFrame:(NSImage*) inFrame andAttributes:(NSDictionary *) theAttributes forTextureID:(NSNumber*) aTextureID forTimestamp:(double)theTimestamp{
    if(self = [super initWithAttributes:theAttributes forTimestamp:theTimestamp]){
        self.frame = inFrame;
        self.textureID = aTextureID;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"frame: %@", self.frame];
}

@end
