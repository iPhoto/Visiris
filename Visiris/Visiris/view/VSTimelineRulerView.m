//
//  VSTimelineRulerView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineRulerView.h"

@implementation VSTimelineRulerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    [[NSColor whiteColor] set];
    
    for(int i = 0; i < dirtyRect.size.width; i += 20){
        NSPoint startPoint = NSMakePoint(i, 0);
        NSPoint endPoint = NSMakePoint(i, dirtyRect.size.height);
        
        [NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
    }
    
}

@end
