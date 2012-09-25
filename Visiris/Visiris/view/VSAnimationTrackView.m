//
//  VSAnimationTrackView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTrackView.h"

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
    [[self trackColor] setFill];
    
    NSRectFill(dirtyRect);
    [self.delegate frameOfView:self wasSetFrom:NSZeroRect to:NSZeroRect];
    
    [[NSColor greenColor] setStroke];
    
    for(NSBezierPath *connectionPath in self.keyFrameConnectionPaths){
        [connectionPath stroke];
    }
}

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
    
}

@end
