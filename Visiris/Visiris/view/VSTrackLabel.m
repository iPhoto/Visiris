//
//  VSTrackLabel.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackLabel.h"

@implementation VSTrackLabel

@synthesize name = _name;
@synthesize trackID = _trackID;
@synthesize frame = _frame;

#pragma mark - Init

-(id) initWithName:(NSString *)aName forTrack:(NSInteger)aTrackID forFrame:(NSRect)aFrame{
    if(self = [super init]){
        self.name = aName;
        self.trackID = aTrackID;
        self.frame = aFrame;
    }
    return self;
}


@end
