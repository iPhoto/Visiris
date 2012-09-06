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

-(BOOL) acceptsFirstResponder{
    return NO;
}

-(BOOL) becomeFirstResponder{
    return NO;
}

-(void) setNextKeyView:(NSView *)next{
    if([self delegateRespondsToSelector:@selector(nextKeyViewOfView:willBeSet:)]){
        next = [self.viewDelegate nextKeyViewOfView:self willBeSet:next];
    }
    
    [super setNextKeyView:next];
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

@end
