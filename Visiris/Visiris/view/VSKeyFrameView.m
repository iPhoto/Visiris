//
//  VSKeyFrameView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import "VSKeyFrameView.h"

@implementation VSKeyFrameView

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
    [[NSColor redColor] setFill];
    NSRectFill(dirtyRect);
}

@end
