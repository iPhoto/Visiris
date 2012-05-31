//
//  VSFlippedView.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 23.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFlippedView.h"

@implementation VSFlippedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(BOOL) isFlipped{
    return YES;
}

@end
