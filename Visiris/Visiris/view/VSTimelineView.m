 //
//  VSTimelinView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineView.h"

#import "VSCoreServices.h"

@implementation VSTimelineView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor greenColor] set];
    NSRectFill(dirtyRect);
}

-(void) awakeFromNib{

}

-(BOOL) acceptsFirstResponder{
    return YES;
}

-(void) keyDown:(NSEvent *)theEvent{
    DDLogInfo(@"Key Down to %@",[self nextResponder] );
    [[self nextResponder] keyDown:theEvent];
    
    
    
    if([self delegateRespondsToSelector:@selector(didReceiveKeyDownEvent:)]){
        [self.delegate didReceiveKeyDownEvent:theEvent];
    }
}

#pragma mark- VSTrackViewDelegate implementation

-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    [super setFrame:frameRect];
    
    //If the width of the frame has changed, the delegate's viewDidResizeFromWidth is called
    if(oldFrame.size.width != self.frame.size.width){
        if(delegate){
            if([delegate conformsToProtocol:@protocol(VSTimelineViewDelegate) ]){
                if([delegate respondsToSelector:@selector(viewDidResizeFromWidth:toWidth:)]){
                    [delegate viewDidResizeFromWidth:oldFrame.size.width toWidth:self.frame.size.width];
                }
            }
        }
        
    }
}
    
#pragma mark - Private Methods
       
       /**
        * Checks if the delegate is able to respond to the given Selector
        * @param selector Selector the delegate will be checked for if it is able respond to
        * @return YES if the delegate is able to respond to the selector, NO otherweis
        */
       -(BOOL) delegateRespondsToSelector:(SEL) selector{
           if(self.delegate){
               if([self.delegate conformsToProtocol:@protocol(VSTimelineViewDelegate) ]){
                   if([self.delegate respondsToSelector: selector]){
                       return YES;
                   }
               }
           }
           
           return NO;
       }

    @end
