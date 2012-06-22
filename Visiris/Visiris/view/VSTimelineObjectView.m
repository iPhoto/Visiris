//
//  VSTimelineObjectView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectView.h"

#import "VSCoreServices.h"

#define RESIZING_FROM_LEFT 0
#define RESIZING_FROM_RIGHT 1

@interface VSTimelineObjectView ()


/** If YES the view is resized on mouseDragged-Event */
@property BOOL resizing;

/** Indicates if the the left- or the rightResizingArea was clicked before teh resizing was started */
@property NSInteger resizingDirection;

/** stores the last mousePosition during a dragging-Operation */
@property NSPoint lastMousePosition;

/** Mouse position when a mous down event happend */
@property NSPoint mouseDownMousePosition;

/** Stores the distance from the x-Origin of the frame and mouse position in the mouseDown. */
@property NSInteger mouseDownXOffset;

/** Area at the left side of the VSTimelineObject which starts the resizing of the object when clicked */
@property NSRect leftResizingArea;

/** Area at the right side of the VSTimelineObject which starts the resizing of the object when clicked */
@property NSRect rightResizingArea;

@end

@implementation VSTimelineObjectView

// Widht of the two resizing areas 
static int resizingAreaWidth = 10;

@synthesize delegate                = _delegate;
@synthesize selected                = _selected;
@synthesize moving                  = _dragged;
@synthesize temporary               = _temporary;
@synthesize intersectionRect        = _intersectionRect;
@synthesize intersected             = _intersected;
@synthesize lastMousePosition       = _lastMousePosition;
@synthesize mouseDownMousePosition  = _mouseDownMousePosition;
@synthesize mouseDownXOffset        = _mouseDownXOffset;
@synthesize leftResizingArea        = _leftResizingArea;
@synthesize rightResizingArea       = _rightResizingArea;
@synthesize resizing                = _resizing;
@synthesize resizingDirection       = _resizingDirection;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayerStyle];
        [self setResizingAreas];
        //        [self initTrackingAreas];
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


/**
 * Inits the layer of the view
 */
-(void) initLayerStyle{
    [self setWantsLayer:YES];
    [self.layer setZPosition:0];
    
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    self.layer.borderColor =  [[NSColor yellowColor] CGColor];
}

/**
 * Sets the frames of the two resizing areas and registrates them as cursorRects
 */
-(void) setResizingAreas{
    [self updateResizingRects];
    
    [self addCursorRect:self.leftResizingArea cursor:[NSCursor resizeLeftRightCursor]];
    [self addCursorRect:self.rightResizingArea cursor:[NSCursor resizeLeftRightCursor]];
    
}

#pragma mark - NSView

-(void) resetCursorRects{
    [super resetCursorRects];
    [self setResizingAreas];
}

- (void)drawRect:(NSRect)dirtyRect{
    
    if(self.intersected){
        [[NSColor greenColor] set];
        NSRectFill(self.intersectionRect);  
        self.layer.opacity = 0.7;
    }
    
    //draws a border around the view if it is selected
    if(self.selected){
        
        self.layer.borderWidth = 3.0;
    }
    else{
        self.layer.borderWidth = 0.0;
    }
    
    if(self.moving || self.temporary || self.resizing){
        self.layer.opacity = 0.7;
        self.layer.borderWidth = 0.0;
    }
    else {
        self.layer.opacity = 1.0;
    }
}

#pragma mark - Event Handling

-(BOOL) acceptsFirstResponder{
    return YES;
}


#pragma mark - Mouse Events

-(void) mouseDown:(NSEvent *)theEvent{
    
    self.lastMousePosition = [theEvent locationInWindow];
    self.mouseDownMousePosition = self.lastMousePosition;
    self.mouseDownXOffset = self.mouseDownMousePosition.x - self.frame.origin.x;
    
    //If the cmd key is pressed the object gets selected additionally
    if(!self.selected){
        if(theEvent.modifierFlags & NSCommandKeyMask){
        }
        if([self delegateImplementsSelector:@selector(timelineObjectViewWasClicked:withModifierFlags:)]){
            [self.delegate timelineObjectViewWasClicked:self withModifierFlags:theEvent.modifierFlags];
        }
    }
    else{
        [self setDraggingModeDependingOnMousePosition:self.lastMousePosition];
    }
}


-(void) mouseDragged:(NSEvent *)theEvent{
    
    NSPoint newMousePosition =[theEvent locationInWindow];
    NSInteger mouseXDelta = newMousePosition.x- self.lastMousePosition.x;
    
    if(!self.resizing && !self.moving){
        [self setDraggingModeDependingOnMousePosition:newMousePosition];
    }
    
    if(self.resizing){
        [self resize:mouseXDelta];
    }
    else if(self.moving){
        [self move:newMousePosition];
    }
    
    self.lastMousePosition = newMousePosition;
}

-(void) cursorUpdate:(NSEvent *)event{
    if(self.resizing){
        [[NSCursor resizeLeftRightCursor] set];
    }
}

-(void) mouseUp:(NSEvent *)theEvent{
    
    if(self.moving){
        self.moving = NO;
        
        if([self delegateImplementsSelector:@selector(timelineObjectDidStopDragging:)]){
            [self.delegate timelineObjectDidStopDragging:self];
        }
    }
    
    if(self.resizing){
        [[NSCursor resizeLeftRightCursor] pop];
        self.resizing = NO;
        self.resizingDirection = -1;
        
        if ([self delegateImplementsSelector:@selector(timelineObjectDidStopResizing:)]) {
            [self.delegate timelineObjectDidStopResizing:self];
        }
    }
}

#pragma mark - Private Methods

-(void) setDraggingModeDependingOnMousePosition:(NSPoint) newMousePosition{
    //sets if the view is moved or resized while dragged
    if(!self.resizing && !self.moving){
        //if the mouse is over on of the resizingAreas the view can be resized
        if(NSPointInRect([self convertPoint:newMousePosition fromView:nil], self.leftResizingArea) || NSPointInRect([self convertPoint:newMousePosition fromView:nil], self.rightResizingArea)){
            
            if ([self delegateImplementsSelector:@selector(timelineObjectWillStartResizing:)]) {
                self.resizing = [self.delegate timelineObjectWillStartResizing:self];
            }
            if(self.resizing){
                
                [[NSCursor resizeLeftRightCursor] push];
                
                if(NSPointInRect([self convertPoint:newMousePosition fromView:nil], self.leftResizingArea)){
                    self.resizingDirection = RESIZING_FROM_LEFT;
                }
                else{
                    self.resizingDirection = RESIZING_FROM_RIGHT;
                }
            }
        }
        else if([self delegateImplementsSelector:@selector(timelineObjectViewWillStartDragging:)]){
            self.moving = [self.delegate timelineObjectViewWillStartDragging:self];
        }   
    }
    
    if(self.resizing && self.moving){
        [self setNeedsDisplay:YES];
    }
}

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

/**
 * Resizes the view according to given size change
 * @param deltaSize Change of the size since the last call
 */
-(void) resize:(NSInteger) deltaSize{
    NSRect resizedFrame = self.frame;
    
    //if the view is resized from the left, the x-origin and width have to be changed     
    if (self.resizingDirection == RESIZING_FROM_LEFT) {
        resizedFrame.size.width -= deltaSize;
        resizedFrame.origin.x += deltaSize;
    }
    else if(self.resizingDirection == RESIZING_FROM_RIGHT){
        resizedFrame.size.width += deltaSize;
    }
    
    //informs the delegate about the resizing
    if([self delegateImplementsSelector:@selector(timelineObjectWillResize:fromFrame:toFrame:)]){
        resizedFrame = [self.delegate timelineObjectWillResize:self fromFrame:self.frame toFrame:resizedFrame];
    }
    
    [self setFrame:resizedFrame];
    
    
    //informs the delegate that view has been resized
    if([self delegateImplementsSelector:@selector(timelineObjectViewWasResized:)]){
        [self.delegate timelineObjectViewWasResized:self];
    }
    [self setNeedsDisplay:YES];
    
}

/**
 * Moves the view according to given change of its x-Origin
 * @param currentMousePosition Current Position of the mouse
 */
-(void) move:(NSPoint) currentMousePosition{
    
    NSPoint newFramesOrigin = NSMakePoint(currentMousePosition.x-self.mouseDownXOffset, self.frame.origin.y);
    
    //informs the delegate about the change 
    if([self delegateImplementsSelector:@selector(timelineObjectViewWillBeDragged:fromPosition:toPosition:forMousePosition:)]){
        newFramesOrigin = [self.delegate timelineObjectViewWillBeDragged:self fromPosition:self.frame.origin toPosition:newFramesOrigin forMousePosition:  currentMousePosition];
    }
    
    [self setFrameOrigin:newFramesOrigin];  
    
    //informs the delegate that the view was moved
    if([self delegateImplementsSelector:@selector(timelineObjectViewWasDragged:)]){
        [self.delegate timelineObjectViewWasDragged:self];
    }
    
    [self setNeedsDisplay:YES];
}

/**
 * Recalculates the resizingAreas according to the current frame of the view
 */
-(void) updateResizingRects{
    self.leftResizingArea= NSMakeRect(0, 0, resizingAreaWidth, self.frame.size.height);
    self.rightResizingArea = NSMakeRect(self.frame.size.width - resizingAreaWidth, 
                                        0, resizingAreaWidth, self.frame.size.height);
}


@end
