//
//  VSKeyFrameView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import "VSKeyFrameView.h"

@interface VSKeyFrameView()

@property NSPoint mouseDownOffset;

@end

@implementation VSKeyFrameView

@synthesize moving      = _moving;
@synthesize selected    = _selected;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void) initLayer{
    [self setWantsLayer:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
}

-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent{
    return YES;
}

-(void) mouseDown:(NSEvent *)theEvent{
    if([self delegateRespondsToSelector:@selector(mouseDown:onView:)]){
        [self.mouseDelegate mouseDown:theEvent onView:self];
    }
    
    NSPoint currentMousePosition = [theEvent locationInWindow];
    
    self.mouseDownOffset = NSMakePoint(currentMousePosition.x - self.frame.origin.x, currentMousePosition.y - self.frame.origin.y);
}

-(void) mouseDragged:(NSEvent *)theEvent{
    NSPoint newMousePosition =[theEvent locationInWindow];
    
    NSPoint newOrigin = NSMakePoint(newMousePosition.x-self.mouseDownOffset.x, newMousePosition.y-self.mouseDownOffset.y);
    
    if([self delegateRespondsToSelector:@selector(view:wantsToBeDraggedFrom:to:)]){
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
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.mouseDelegate){
        if([self.mouseDelegate conformsToProtocol:@protocol(VSViewMouseEventsDelegate)]){
            if([self.mouseDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

-(void) setLayerStyle{
    [self.layer setOpacity:1.0];
    [self.layer setBackgroundColor:[[NSColor redColor]CGColor]];
     [self.layer setBorderWidth:0];
    if(self.selected){
        [self.layer setBorderColor:[[NSColor yellowColor] CGColor]];
        [self.layer setBorderWidth:1];
    }
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
