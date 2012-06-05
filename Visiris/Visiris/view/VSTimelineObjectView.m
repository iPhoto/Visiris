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

/** indicates wheter it's allowed to be dragged around or not */
@property BOOL dragged;

@property BOOL resizing;

/** stores the last mousePosition during a dragging-Operation */
@property NSPoint lastMousePosition;

@property NSRect oldFrame;

@property NSRect leftResizingArea;

@property NSRect rightResizingArea;

@end

@implementation VSTimelineObjectView

static int trackingAreaWidth = 10;

@synthesize delegate = _delegate;
@synthesize selected = _selected;
@synthesize dragged = _dragged;
@synthesize temporary = _temporary;
@synthesize intersectionRect = _intersectionRect;
@synthesize intersected =_intersected;
@synthesize lastMousePosition = _lastMousePosition;
@synthesize oldFrame = _oldFrame;
@synthesize leftResizingArea = _leftResizingArea;
@synthesize rightResizingArea = _rightResizingArea;
@synthesize resizing = _resizing;

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


/**
 * Inits the layer of the view
 */
-(void) initLayerStyle{
    [self setWantsLayer:YES];
    self.layer.cornerRadius = 10.0;
    self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
    self.layer.borderColor =  [[NSColor yellowColor] CGColor];
}

-(void) setResizingAreas{
    [self updateResizingRects];
    
    [self addCursorRect:self.leftResizingArea cursor:[NSCursor resizeLeftRightCursor]];
    [self addCursorRect:self.rightResizingArea cursor:[NSCursor resizeLeftRightCursor]];
    
}

-(void) resetCursorRects{
    [super resetCursorRects];
    
    [self setResizingAreas];
}

-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent{
    return YES;
}

-(void) updateResizingRects{
    self.leftResizingArea= NSMakeRect(0, 0, trackingAreaWidth, self.frame.size.height);
    self.rightResizingArea = NSMakeRect(self.frame.size.width - trackingAreaWidth, 
                                        0, trackingAreaWidth, self.frame.size.height);
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
    self.lastMousePosition = [theEvent locationInWindow];
    
     if([self delegateImplementsSelector:@selector(timelineObjectViewWasClicked:)]){
        [self.delegate timelineObjectViewWasClicked:self];
    }
    
    self.lastMousePosition = [theEvent locationInWindow];
}


-(void) mouseDragged:(NSEvent *)theEvent{
    
    if(!self.resizing && !self.dragged){
        if(NSPointInRect(self.lastMousePosition, self.leftResizingArea) || NSPointInRect(self.lastMousePosition, self.rightResizingArea)){
            self.resizing = YES;
        }
        else if([self delegateImplementsSelector:@selector(timelineObjectViewWillStartDragging:)]){
            self.dragged = [self.delegate timelineObjectViewWillStartDragging:self];
        }
        
    }
    
    if(self.resizing){
        if([self delegateImplementsSelector:@selector(timelineObjectIsResizing:fromFrame:toFrame:)]){
            [self.delegate timelineObjectIsResizing:self fromFrame:self.oldFrame toFrame:self.frame];
            self.oldFrame = self.frame;
        }
    }
    else if(self.dragged){
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

-(void) mouseMoved:(NSEvent *)theEvent{
    DDLogInfo(@"movin");
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
