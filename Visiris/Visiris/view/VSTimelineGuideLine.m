//
//  VSTimelineGuideLine.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineGuideLine.h"

@implementation VSTimelineGuideLine
@synthesize lineStartPoint  = _lineStartPoint;
@synthesize lineEndPoint    = _lineEndPoint;

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
    [[NSColor redColor] set];
//    NSRectlFill(dirtyRect);
   
    self.lineEndPoint = NSMakePoint(self.lineStartPoint.x, self.frame.origin.y - self.frame.size.height);
    
    [NSBezierPath strokeLineFromPoint:self.lineStartPoint toPoint:self.lineEndPoint];
}

@end
