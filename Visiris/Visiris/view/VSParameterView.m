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

@synthesize fillColor   = _fillColor;

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

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
}

#pragma mark - Private Methods


#pragma mark - Properties

-(void) setFillColor:(NSColor *)fillColor{
    _fillColor = fillColor;
    [self.fillColor setFill];
}

-(NSColor*) fillColor{
    return _fillColor;
}

@end
