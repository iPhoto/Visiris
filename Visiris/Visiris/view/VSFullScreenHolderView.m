//
//  VSFullScreenHolderView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 03.10.12.
//
//

#import "VSFullScreenHolderView.h"

@implementation VSFullScreenHolderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



-(BOOL) acceptsFirstResponder{
    return YES;
}

-(void) keyDown:(NSEvent *)theEvent{
    if([self keyDownDelegateRespondsToSelector:@selector(view:didReceiveKeyDownEvent:)]){
        [self.keyDownDelegate view:self didReceiveKeyDownEvent:theEvent];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor blackColor] setFill];
    
    NSRectFill(dirtyRect);
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) keyDownDelegateRespondsToSelector:(SEL) selector{
    if(self.keyDownDelegate){
        if([self.keyDownDelegate conformsToProtocol:@protocol(VSViewKeyDownDelegate)]){
            if([self.keyDownDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

@end
