//
//  VSTimelineObjectView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectView.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectView ()
@property BOOL dragged;
@property NSPoint lastMousePosition;
@end

@implementation VSTimelineObjectView

@synthesize delegate = _delegate;
@synthesize selected = _selected;
@synthesize dragged = _dragged;
@synthesize temporary = _temporary;
@synthesize intersectionRect = _intersectionRect;
@synthesize intersected =_intersected;
@synthesize lastMousePosition = _lastMousePosition;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayerStyle];
    }
    
    return self;
}

-(void) initLayerStyle{
    [self setWantsLayer:YES];
    self.layer.cornerRadius = 10.0;
    self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
    self.layer.borderColor =  [[NSColor yellowColor] CGColor];
}

-(void) awakeFromNib{
    [self  unregisterDraggedTypes];
    
    //Unregisters all Subviews from their draggTypes, thus they won't react on dragging
    for(NSView *subView in [self subviews]){
        [subView unregisterDraggedTypes];
    }
}

- (void)drawRect:(NSRect)dirtyRect{
    
    //draws a border around the view if it is selected
    if(self.selected){
        
        self.layer.borderWidth = 3.0;
    }
    else{
        self.layer.borderWidth = 0.0;
    }
    

    if(self.dragged || self.temporary){
        self.layer.opacity = 0.7;
        self.layer.borderWidth = 0.0;
    }
    else {
        self.layer.opacity = 1.0;
    }
    
    if(self.intersected){
        [[NSColor greenColor] set];
        NSRectFill(self.intersectionRect);
        self.layer.opacity = 0.7;
    }
}

#pragma mark - Mouse Events

-(void) mouseDown:(NSEvent *)theEvent{
    if([self delegateImplementsSelector:@selector(timelineObjectViewWasClicked:)]){
        [self.delegate timelineObjectViewWasClicked:self];
    }
    
    self.lastMousePosition = [theEvent locationInWindow];
}


-(void) mouseDragged:(NSEvent *)theEvent{
    if(!self.dragged){
        if([self delegateImplementsSelector:@selector(timelineObjectViewWillStartDragging:)]){
            self.dragged = [self.delegate timelineObjectViewWillStartDragging:self];
        }
        
    }
    if(self.dragged){
        NSPoint newMousePosition =[theEvent locationInWindow];
        if([self delegateImplementsSelector:@selector(timelineObjectIsDragged:fromPosition:toPosition:)]){
            [self.delegate timelineObjectIsDragged:self fromPosition:self.lastMousePosition toPosition: newMousePosition ];
            self.lastMousePosition = newMousePosition;
        }
    }
}

-(void) mouseUp:(NSEvent *)theEvent{
    if(self.dragged){
        self.dragged = NO;
        
        if([self delegateImplementsSelector:@selector(timelineObjectDidStopDragging:)]){
            [self.delegate timelineObjectDidStopDragging:self];
        }
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
