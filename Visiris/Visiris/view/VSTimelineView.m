//
//  VSTimelinView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineView.h"

#import "VSCoreServices.h"

@implementation VSTimelineView

@synthesize timelineViewDelegate    = _timelineViewDelegate;
@synthesize mouseMoveDelegate       = _mouseMoveDelegate;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor darkGrayColor] set];
    NSRectFill(dirtyRect);
}

-(BOOL) isFlipped{
    return YES;
}

#pragma mark - Event Handling

-(BOOL) acceptsFirstResponder{
    return YES;
}

-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent{
    return YES;
}


-(void) keyDown:(NSEvent *)theEvent{
    if([self timelineViewDelegateRespondsToSelector:@selector(didReceiveKeyDownEvent:)]){
        [self.timelineViewDelegate didReceiveKeyDownEvent:theEvent];
    }
}

-(void) mouseDragged:(NSEvent *)theEvent{
    if([self mouseMoveDelegateRespondsToSelector:@selector(mouseDragged:onView:)]) {
        [self.mouseMoveDelegate mouseDragged:theEvent onView:self];
    }
        
}

#pragma mark- VSTrackViewDelegate implementation

-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    [super setFrame:frameRect];
    
    //If the width of the frame has changed, the delegate's viewDidResizeFromWidth is called
    if(!NSEqualRects(oldFrame, self.frame)){
        if(self.timelineViewDelegate){
            if([self.timelineViewDelegate conformsToProtocol:@protocol(VSTimelineViewDelegate) ]){
                if([self.timelineViewDelegate respondsToSelector:@selector(viewDidResizeFromFrame:toFrame:)]){
                    [self.timelineViewDelegate viewDidResizeFromFrame:oldFrame toFrame:self.frame];
                }
            }
        }
        
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) timelineViewDelegateRespondsToSelector:(SEL) selector{
    if(self.timelineViewDelegate != nil){
        if([self.timelineViewDelegate conformsToProtocol:@protocol(VSTimelineViewDelegate) ]){
            if([self.timelineViewDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) mouseMoveDelegateRespondsToSelector:(SEL) selector{
    if(self.mouseMoveDelegate != nil){
        if([self.mouseMoveDelegate conformsToProtocol:@protocol(VSViewMouseEventsDelegate) ]){
            if([self.mouseMoveDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

@end
