//
//  VSKeyFrameView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import "VSKeyFrameView.h"

#import <QuartzCore/QuartzCore.h>

@interface VSKeyFrameView()

/** Stores the Mouse-Position in mouseDown. Neccessary for computing the right position in mouseDragged */
@property NSPoint mouseDownOffset;

@end



@implementation VSKeyFrameView

@synthesize moving      = _moving;
@synthesize selected    = _selected;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayer];
    }
    
    return self;
}

/**
 * Inits the view's layer
 */
-(void) initLayer{
    [self setWantsLayer:YES];
    self.layer = [[CALayer alloc] init];
    [self.layer setZPosition:1];
    [self setLayerStyle];
}

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
}

-(void) setFrame:(NSRect)frameRect{
    NSRect fromFrame = self.frame;
    
    [super setFrame:frameRect];
    
    if([self resizingDelegateRespondsToSelector:@selector(frameOfView:wasSetFrom:to:)]){
        [self.resizingDelegate frameOfView:self wasSetFrom:fromFrame to:self.frame];
    }
}


-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent{
    return YES;
}

#pragma mark - Event Handling

-(void) mouseDown:(NSEvent *)theEvent{
    if([self mouseDelegateRespondsToSelector:@selector(mouseDown:onView:)]){
        [self.mouseDelegate mouseDown:theEvent onView:self];
    }
    
    NSPoint currentMousePosition = [theEvent locationInWindow];
    
    self.mouseDownOffset = NSMakePoint(currentMousePosition.x - self.frame.origin.x, currentMousePosition.y - self.frame.origin.y);
}

-(void) mouseDragged:(NSEvent *)theEvent{
    NSPoint newMousePosition =[theEvent locationInWindow];
    
    NSPoint newOrigin = NSMakePoint(newMousePosition.x-self.mouseDownOffset.x, newMousePosition.y-self.mouseDownOffset.y);
    
    if([self mouseDelegateRespondsToSelector:@selector(view:wantsToBeDraggedFrom:to:)]){
        newOrigin = [self.mouseDelegate view:self wantsToBeDraggedFrom:self.frame.origin to:newOrigin];
    }
    
    [self setFrameOrigin:newOrigin];
    
}

#pragma mark - Private Methods

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) mouseDelegateRespondsToSelector:(SEL) selector{
    if(self.mouseDelegate){
        if([self.mouseDelegate conformsToProtocol:@protocol(VSViewMouseEventsDelegate)]){
            if([self.mouseDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) resizingDelegateRespondsToSelector:(SEL) selector{
    if(self.resizingDelegate){
        if([self.resizingDelegate conformsToProtocol:@protocol(VSViewResizingDelegate)]){
            if([self.resizingDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

/**
 * Set's the style of the view's layer according to its current state
 */
-(void) setLayerStyle{
    [CATransaction begin];

    
    [self.layer setOpacity:1.0];
    [self.layer setBackgroundColor:[[NSColor redColor]CGColor]];
    
    if(self.selected){
        [self.layer setBackgroundColor:[[NSColor greenColor]CGColor]];
        [self.layer setBorderColor:[[NSColor yellowColor] CGColor]];
        [self.layer setBorderWidth:1];
    }
    else{
        [self.layer setBorderWidth:0];
    }
    [CATransaction commit];
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

@end
