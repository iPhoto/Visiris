//
//  VSAnimationTrackView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTrackView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTrackView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    [[self trackColor] setFill];
    
    NSRectFill(dirtyRect);
    
    
    [[NSColor greenColor] setStroke];
    
    
    for(NSBezierPath *connectionPath in self.keyFrameConnectionPaths){
        [connectionPath setLineWidth:2];
        [connectionPath stroke];
    }
    

}

-(void) rightMouseDown:(NSEvent *)theEvent{
    if( [self viewMouseDelegateRespondsToSelector:@selector(rightMouseDown:)]){
        [self.viewMouseDelegate rightMouseDown:theEvent onView:self];
    }
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) viewMouseDelegateRespondsToSelector:(SEL) selector{
    if(self.viewMouseDelegate){
        if([self.viewMouseDelegate conformsToProtocol:@protocol(VSViewMouseEventsDelegate)]){
            if([self.viewMouseDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

@end
