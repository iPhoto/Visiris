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

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.viewDelegate){
        if([self.viewDelegate conformsToProtocol:@protocol(VSViewDelegate) ]){
            if([self.viewDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Properties

-(void) setFillColor:(NSColor *)fillColor{
    _fillColor = fillColor;
    [self.fillColor setFill];
}

-(NSColor*) fillColor{
    return _fillColor;
}

@end
