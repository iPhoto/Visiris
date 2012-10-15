//
//  VSTimelinView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineView.h"

#import "VSCoreServices.h"

@interface VSTimelineView()

/** NSTrackingArea covering the whole frame of the view to make it first responder as soon as the mouse enters the view*/
@property NSTrackingArea *trackingArea;

@end

@implementation VSTimelineView

@synthesize resizingDelegate    = _timelineViewDelegate;
@synthesize mouseMoveDelegate       = _mouseMoveDelegate;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways ) owner:self userInfo:nil];
        [self addTrackingArea:self.trackingArea];
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
    if([self keyDownDelegateRespondsToSelector:@selector(view:didReceiveKeyDownEvent:)]){
        [self.keyDownDelegate view:self didReceiveKeyDownEvent:theEvent];
        
    }

}

-(void) mouseDragged:(NSEvent *)theEvent{
    if([self mouseMoveDelegateRespondsToSelector:@selector(mouseDragged:onView:)]) {
        [self.mouseMoveDelegate mouseDragged:theEvent onView:self];
    }
}

-(void) mouseEntered:(NSEvent *)theEvent{
    //tells the window to make the view to firstResponder as soon as the mouse is over the trackingArea covering the whole view
    [self.window makeFirstResponder:self];
}

#pragma mark- VSTrackViewDelegate implementation

-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    [super setFrame:frameRect];
    
    //If the width of the frame has changed, the delegate's viewDidResizeFromWidth is called
    if(!NSEqualRects(oldFrame, self.frame)){
        if([self viewResizingDelegateRespondsToSelector:@selector(frameOfView:wasSetFrom:to:)]){
            [self.resizingDelegate frameOfView:self wasSetFrom:oldFrame to:self.frame];
        }
    }
    
    if([self.trackingAreas containsObject:self.trackingArea]){
        [self removeTrackingArea:self.trackingArea];
    }
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways ) owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    
    //    DDLogInfo(@"tracking Area of %@: %@",NSStringFromClass([self class]), NSStringFromRect(self.trackingArea.rect));
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) viewResizingDelegateRespondsToSelector:(SEL) selector{
    if(self.resizingDelegate != nil){
        if([self.resizingDelegate conformsToProtocol:@protocol(VSViewResizingDelegate) ]){
            if([self.resizingDelegate respondsToSelector: selector]){
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

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) keyDownDelegateRespondsToSelector:(SEL) selector{
    if(self.mouseMoveDelegate != nil){
        if([self.mouseMoveDelegate conformsToProtocol:@protocol(VSViewKeyDownDelegate) ]){
            if([self.mouseMoveDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

@end
