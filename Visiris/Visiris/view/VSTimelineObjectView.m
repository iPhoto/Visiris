//
//  VSTimelineObjectView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectView.h"

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

/** frame of the view in the mouseDown event */
@property NSRect frameAtMouseDown;

@end

@implementation VSTimelineObjectView

// Widht of the two resizing areas 
static int resizingAreaWidth = 10;

@synthesize delegate                = _delegate;
@synthesize selected                = _selected;
@synthesize moving                  = _moving;
@synthesize temporary               = _temporary;
@synthesize lastMousePosition       = _lastMousePosition;
@synthesize mouseDownMousePosition  = _mouseDownMousePosition;
@synthesize mouseDownXOffset        = _mouseDownXOffset;
@synthesize frameAtMouseDown        = _frameAtMouseDown;
@synthesize leftResizingArea        = _leftResizingArea;
@synthesize rightResizingArea       = _rightResizingArea;
@synthesize resizing                = _resizing;
@synthesize resizingDirection       = _resizingDirection;
@synthesize inactive                = _inactive;
@synthesize doubleFrame             = _doubleFrame;



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setResizingAreas];
    }
    
    return self;
}

-(void) awakeFromNib{
    [self  unregisterDraggedTypes];
    [self initLayerStyle];
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
    
    [self setDefaultLayerStyle];
}

-(void) setDefaultLayerStyle{
    self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
    self.layer.cornerRadius = 5.0;
    self.layer.opacity = 1.0;
    self.layer.borderWidth = 0.0;
}

-(void) setLayerStyle{
    if(!self.inactive){
        
        [self setDefaultLayerStyle];
        
        if(self.selected){
            self.layer.borderColor =  [[NSColor yellowColor] CGColor];
            self.layer.borderWidth = 3.0;
        }
        
        if (self.moving || self.temporary || self.resizing) {
            self.layer.opacity = 0.5;
        }
    }
    else {
        self.layer.opacity = 0.0;
    }
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

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:NSRectFromVSDoubleFrame(self.doubleFrame)];
}

#pragma mark - Event Handling

-(BOOL) acceptsFirstResponder{
    return YES;
}


#pragma mark - Mouse Events

-(void) mouseDown:(NSEvent *)theEvent{
    
    //stores the current values of mouse, neccessary for latter dragging operations
    self.lastMousePosition = [theEvent locationInWindow];
    self.mouseDownMousePosition = self.lastMousePosition;
    self.mouseDownXOffset = self.mouseDownMousePosition.x - self.frame.origin.x;
    self.frameAtMouseDown = self.frame;
    
    
    if(!self.selected){
        //Calls timelineObjectViewWasClicked from its delegate and handsover the event's modifier flags thus the delegate can decide which kind of selection depending on the keycodes stored in the modifier flags to be performed
        if([self delegateImplementsSelector:@selector(timelineObjectViewWasClicked:withModifierFlags:)]){
            [self.delegate timelineObjectViewWasClicked:self withModifierFlags:theEvent.modifierFlags];
        }
    }
    else{
        [self setDraggingModeDependingOnMousePosition:self.lastMousePosition];
    }
}


-(void) mouseDragged:(NSEvent *)theEvent{
    
    //    float scrollingXDelta = 0.0;
    //    if(self.enclosingScrollView){
    //        NSPoint currentScrollPos = self.enclosingScrollView.contentView.bounds.origin;
    //        [self autoscroll:theEvent];
    //        NSPoint newScrollPos = self.enclosingScrollView.contentView.bounds.origin;
    //        
    //        DDLogInfo(@"scrolled about: %f", currentScrollPos.x - newScrollPos.x);
    //        
    //        scrollingXDelta=currentScrollPos.x - newScrollPos.x;
    //    }
    //    
    //    NSPoint currentScrollPos = self.enclosingScrollView.contentView.bounds.origin;
    //    [self autoscroll:theEvent];
    //    NSPoint newScrollPos = self.enclosingScrollView.contentView.bounds.origin;
    //    
    //    DDLogInfo(@"scrolled about: %f", currentScrollPos.x - newScrollPos.x);
    //    
    //    scrollingXDelta=currentScrollPos.x - newScrollPos.x;
    //
    //    
    NSPoint newMousePosition =[theEvent locationInWindow];
    //    newMousePosition.x += scrollingXDelta;
    //    
    //if the the event was entered first time after a mouse down the kind of drgging operation has to be set
    if(!self.resizing && !self.moving){
        [self setDraggingModeDependingOnMousePosition:newMousePosition];
    }
    
    //dependening on the set drag mode resize or move is called
    if(self.resizing){
        [self resize:newMousePosition];
    }
    else if(self.moving){
        [self move:newMousePosition];
    }
    
    self.lastMousePosition = newMousePosition;
    
    [self autoscroll:theEvent];
}

-(void) cursorUpdate:(NSEvent *)event{
    //if a resizing is happening a different cursor is shown
    if(self.resizing){
        [[NSCursor resizeLeftRightCursor] set];
    }
}

-(void) mouseUp:(NSEvent *)theEvent{
    
    [self mouseDragged:theEvent];
    
    if(self.moving){
        //sets the moving-flag to NO and tells its delegate that the draggin has ended
        self.moving = NO;
        
        if([self delegateImplementsSelector:@selector(timelineObjectDidStopDragging:)]){
            [self.delegate timelineObjectDidStopDragging:self];
        }
    }
    else if(self.resizing){
        //Resets the cursor and the resizingDirection and set the resizing flag to NO
        [[NSCursor resizeLeftRightCursor] pop];
        self.resizing = NO;
        self.resizingDirection = -1;
        
        //tells its delegate that the resizing operation has been finished
        if ([self delegateImplementsSelector:@selector(timelineObjectDidStopResizing:)]) {
            [self.delegate timelineObjectDidStopResizing:self];
        }
    }
}


#pragma mark - Methods

-(CALayer*) addIntersectionLayerForRect:(NSRect)intersection{
    CALayer *intersectionLayer = [[CALayer alloc] init];
    
    intersectionLayer.frame = intersection;
    intersectionLayer.opacity = 0.5;
    intersectionLayer.backgroundColor = [[NSColor greenColor] CGColor];
    intersectionLayer.cornerRadius = self.layer.cornerRadius;
    [intersectionLayer removeAllAnimations];
    
    [self.layer addSublayer:intersectionLayer];
    
    return intersectionLayer;
}

-(void) removeIntersectionLayer:(CALayer *)intersectionLayer{
    if(intersectionLayer.superlayer == self.layer){
        [intersectionLayer removeFromSuperlayer];
    }
}

#pragma mark - Private Methods

/**
 * Checks if the given mouse-position is in the two resizingRects. If yes the resizing-flag is set to YES and a resizing operation is started, otherwise the moving-flag is set and a moving operation is started
 * @param newMousePosition Mouseposition the dragging starts at
 */
-(void) setDraggingModeDependingOnMousePosition:(NSPoint) newMousePosition{
    
    //sets if the view is moved or resized while dragged
    if(!self.resizing && !self.moving){
        
        //if the mouse is over on of the resizingAreas the view can be resized
        if(NSPointInRect([self convertPoint:newMousePosition fromView:nil], self.leftResizingArea) || NSPointInRect([self convertPoint:newMousePosition fromView:nil], self.rightResizingArea)){
            
            //tells its delegate that it want to start a resizing-operation
            if ([self delegateImplementsSelector:@selector(timelineObjectWillStartResizing:)]) {
                self.resizing = [self.delegate timelineObjectWillStartResizing:self];
            }
            
            //if the delegate has allowed to start a reszing operation it is initializes
            if(self.resizing){
                [self initResizingForMousePosition:newMousePosition];
            }
        }
        //if the resizing flag is still NO a moving operation is started by setting the moving-Flag to YES
        else if([self delegateImplementsSelector:@selector(timelineObjectViewWillStartDragging:)]){
            
            self.moving = [self.delegate timelineObjectViewWillStartDragging:self];
        }   
    }
    
    if(self.resizing && self.moving){
        [self setNeedsDisplay:YES];
    }
}

/**
 * Initializes a resizing operation
 * @param mousePosition Mouseposition the resizing starts at
 */
-(void) initResizingForMousePosition:(NSPoint) mousePosition{
    [[NSCursor resizeLeftRightCursor] push];
    
    if(NSPointInRect([self convertPoint:mousePosition fromView:nil], self.leftResizingArea)){
        self.resizingDirection = RESIZING_FROM_LEFT;
    }
    else{
        self.resizingDirection = RESIZING_FROM_RIGHT;
    }
}

/**
 * Resizes the view according to given size change
 * @param currentMousePosition Current Position of the mouse
 */
-(void) resize:(NSPoint) currentMousePosition{

    VSDoubleFrame resizedFrame = self.doubleFrame;
    
    
    float correctedMousePosition = currentMousePosition.x-self.mouseDownXOffset;
    
    //if the view is resized from the left, the x-origin and width have to be changed     
    if (self.resizingDirection == RESIZING_FROM_LEFT) {
        resizedFrame.width -= correctedMousePosition-resizedFrame.x ;
        resizedFrame.x = correctedMousePosition;
    }
    else if(self.resizingDirection == RESIZING_FROM_RIGHT){
        
        resizedFrame.width = self.frameAtMouseDown.size.width + (correctedMousePosition-resizedFrame.x);
    }
    
    //  DDLogInfo(@"before: %@",NSStringFromRect(resizedFrame));
    //informs the delegate about the resizing
    if([self delegateImplementsSelector:@selector(timelineObjectWillResize:fromFrame:toFrame:)]){
        resizedFrame = [self.delegate timelineObjectWillResize:self fromFrame:self.doubleFrame toFrame:resizedFrame];
    }
    //   DDLogInfo(@"after: %@",NSStringFromRect(resizedFrame));
    [self setDoubleFrame:resizedFrame];
    
    
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

-(void) updateFrame{
    [self setFrame:NSZeroRect];
}

#pragma mark - Properties

-(void) setSelected:(BOOL)selected{
    if(_selected != selected){
        _selected = selected;
        [self setLayerStyle];
    }
}

-(BOOL) selected{
    return _selected;
}

-(void) setMoving:(BOOL)moving{
    if(_moving != moving){
        _moving = moving;
        [self setLayerStyle];
    }
}

-(BOOL) moving{
    return _moving;
}

-(void) setInactive:(BOOL)inactive{
    if(_inactive != inactive){
        _inactive = inactive;
        [self setLayerStyle];
    }
}

-(BOOL) inactive{
    return _inactive;
}

-(void) setTemporary:(BOOL)temporary{
    if(temporary != _temporary){
        _temporary = temporary;
        [self setLayerStyle];
    }
}
  

-(BOOL) temporary{
    return _temporary;
}

-(void) setResizing:(BOOL)resizing{
    if(resizing != _resizing){
        _resizing = resizing;
        [self setLayerStyle];
    }
}

-(BOOL) resizing{
    return _resizing;
}

-(void) setDoubleFrame:(VSDoubleFrame)doubleFrame{
    if(!VSEqualDoubleFrame(_doubleFrame, doubleFrame)){
        _doubleFrame = doubleFrame;
        
        [self updateFrame];
    }
}

-(VSDoubleFrame) doubleFrame{
    return _doubleFrame;
}


@end
