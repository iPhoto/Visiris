//
//  VSPlayHeadView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlayHeadView.h"

#import "VSCoreServices.h"

@interface VSPlayHeadView()

@property NSRect knobRect;

@end

@implementation VSPlayHeadView

@synthesize knobHeight              = _knobHeight;
@synthesize knobRect                = _knobRect;
@synthesize delegate                = _delegate;
@synthesize formerMousePosition     = _formerMousePosition;
@synthesize moving                  = _moving;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.knobRect = self.frame;
        [self updateKnobRect];
    }
    
    return self;
}


#pragma mark - NSView

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
    
    [self updateKnobRect];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor redColor] set];
    NSPoint startPoint = NSMakePoint(dirtyRect.size.width/2, 0);
    NSPoint endPoint = NSMakePoint(dirtyRect.size.width/2, dirtyRect.size.height);
    
    [NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
    
    [[NSColor redColor] set];
    NSRectFill(self.knobRect);
}

#pragma mark- Mouse Events

-(void) mouseDown:(NSEvent *)theEvent{
    if([self delegateRespondsToSelector:@selector(willStartMovingPlayHeadView:)]){
        self.moving =[self.delegate willStartMovingPlayHeadView:self];
    }
    
    self.formerMousePosition = [theEvent locationInWindow];
}

-(void) mouseDragged:(NSEvent *)theEvent{
    NSPoint currentMousePosition = [theEvent locationInWindow];
    
    if(self.moving){
        NSInteger newXPos = currentMousePosition.x + self.frame.size.width / 2.0;
        NSPoint newCenter = NSMakePoint(newXPos, self.frame.origin.y);
        
        NSPoint currentCenter = NSMakePoint(NSMidX(self.frame), self.frame.origin.y);  
        
        if([self delegateRespondsToSelector:@selector(willMovePlayHeadView:FromPosition:toPosition:)]){
            newCenter =[self.delegate willMovePlayHeadView:self FromPosition:currentCenter toPosition:newCenter];
        }
        
        NSPoint newOrigin = NSMakePoint(newCenter.x - self.frame.size.width / 2.0, newCenter.y);
        
        [self setFrameOrigin:newOrigin];
        
        if([self delegateRespondsToSelector:@selector(didMovePlayHeadView:)]){
            [self.delegate didMovePlayHeadView:self];
        }
    }
    
    self.formerMousePosition = currentMousePosition;
}

-(void) mouseUp:(NSEvent *)theEvent{
    if(self.moving){
        if([self delegateRespondsToSelector:@selector(didStopMovingPlayHeadView:)]){
            [self.delegate didStopMovingPlayHeadView:self];
        }
    }
    
    self.moving = NO;
}

#pragma mark - Private Methods

-(void) updateKnobRect{
    self.knobRect = NSMakeRect(0, self.frame.size.height-self.knobHeight, self.frame.size.width, self.knobHeight);
}

/**
 * Checks if the delegate  is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPlayHeadViewDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Properties

-(void) setKnobHeight:(NSInteger)knobHeight{
    _knobHeight = knobHeight;
    
    // if the knobheight has changed the view has to be drawn again
    [self updateKnobRect];
    [self setNeedsDisplay:YES];
}

-(NSInteger) knobHeight{
    return _knobHeight;
}



@end
