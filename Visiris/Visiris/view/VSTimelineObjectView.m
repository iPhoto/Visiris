//
//  VSTimelineObjectView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectView.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectView

@synthesize delegate = _delegate;
@synthesize selected = _selected;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        self.layer.cornerRadius = 10.0;
        self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
    }
    
    return self;
}

-(void) awakeFromNib{
    [self  unregisterDraggedTypes];
    
    //Unregisters all Subviews from their draggTypes, thus they won't react on dragging
    for(NSView *subView in [self subviews]){
        [subView unregisterDraggedTypes];
    }
}

- (void)drawRect:(NSRect)dirtyRect{
    
    if(self.selected){
        self.layer.borderColor =  [[NSColor yellowColor] CGColor];
        self.layer.borderWidth = 3.0;
    }
    else{
        self.layer.borderWidth = 0.0;
    }
}

#pragma mark - Mouse Events

-(void) mouseDown:(NSEvent *)theEvent{
    if([self delegateImplementsSelector:@selector(timelineObjectViewWasClicked:)]){
        [self.delegate timelineObjectViewWasClicked:self];
    }
}

-(void) mouseDragged:(NSEvent *)theEvent{
    if([self delegateImplementsSelector:@selector(timelineObjectViewWasDragged:toPosition:)]){
        [self.delegate timelineObjectViewWasDragged:self toPosition:[self convertPoint:[NSEvent mouseLocation] fromView:nil]];
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateImplementsSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSTimelineObjectViewDelegate) ]){
            if([self.delegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

@end
