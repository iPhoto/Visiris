//
//  VSTestFlippedView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSTestFlippedView.h"

@implementation VSTestFlippedView

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
    // Drawing code here.
    [[NSColor redColor] set];
    
    NSRectFill(dirtyRect);
}

-(BOOL) isFlipped{
    return YES;
}

@end
