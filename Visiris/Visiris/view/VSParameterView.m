//
//  VSParameterView.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameterView.h"
#import "VSParameter.h"


@implementation VSParameterView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - NSView

-(void) drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    [self.fillColor setFill];
    NSRectFill(dirtyRect);
}

@end
