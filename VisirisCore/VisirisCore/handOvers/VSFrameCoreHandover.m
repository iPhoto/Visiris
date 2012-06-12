//
//  VSFrameCoreHandover.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameCoreHandover.h"
#import "VSImage.h"

@implementation VSFrameCoreHandover

@synthesize frame       = _frame;
@synthesize textureID   = _textureID;

-(id) initWithFrame:(VSImage *) inFrame andAttributes:(NSDictionary *) theAttributes forTextureID:(GLuint) aTextureID forTimestamp:(double)theTimestamp{
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
