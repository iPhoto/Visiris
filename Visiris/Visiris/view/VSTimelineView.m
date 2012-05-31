//
//  VSTimelinView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineView.h"

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
    
    @end
