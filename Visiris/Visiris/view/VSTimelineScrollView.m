//
//  VSTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineScrollView.h"

#import "VSCoreServices.h"

@implementation VSTimelineScrollView

@synthesize zoomingDelegate = _zoomingDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}


#pragma mark - Mouse Events

-(void) scrollWheel:(NSEvent *)theEvent{
    if(!([theEvent modifierFlags] & NSCommandKeyMask)){
        [super scrollWheel:theEvent];
    }
    else {
        if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wantsToBeZoomedAccordingToScrollWheel:atPosition:)]){
            [self.zoomingDelegate timelineScrollView:self wantsToBeZoomedAccordingToScrollWheel:[theEvent deltaY] atPosition:[theEvent locationInWindow]];
        }
    }
}

-(void) magnifyWithEvent:(NSEvent *)event{
    
    if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wantsToBeZoomedAccordingToScrollWheel:atPosition:)]){
        [self.zoomingDelegate timelineScrollView:self wantsToBeZoomedAccordingToScrollWheel:[event magnification] atPosition:[event locationInWindow]];
    }
}



#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) zoomingDelegateImplementsSelector:(SEL) selector{
    if(self.zoomingDelegate){
        if([self.zoomingDelegate conformsToProtocol:@protocol(VSTimelineScrollViewZoomingDelegate) ]){
            if([self.zoomingDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

-(id<CAAction>) actionForLayer:(CALayer *)layer forKey:(NSString *)event{
    return nil;
}

//-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
//    DDLogInfo(@"drawing l");
//}


@end
