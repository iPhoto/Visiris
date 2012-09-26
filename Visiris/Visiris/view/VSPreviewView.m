//
//  VSPreviewView.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPreviewView.h"
#import "VSCoreServices.h"

@implementation VSPreviewView

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(void) awakeFromNib{
    
}

#pragma mark - NSView

-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    
    [super setFrame:frameRect];
    
    //tells its delegate that the view's frame was resized
    if([self frameResizingDelegateRespondsToSelector:@selector(frameOfView:wasSetFrom:to:)]){
        [self.frameResizingDelegate frameOfView:self wasSetFrom:oldFrame to:self.frame];
    }
}

-(void) viewDidEndLiveResize{
    if([self frameResizingDelegateRespondsToSelector:@selector(viewDidEndLiveResizing:)]){
        [self.frameResizingDelegate viewDidEndLiveResizing:self];
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) frameResizingDelegateRespondsToSelector:(SEL) selector{
    if(self.frameResizingDelegate != nil){
        if([self.frameResizingDelegate conformsToProtocol:@protocol(VSViewResizingDelegate) ]){
            if([self.frameResizingDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

@end
