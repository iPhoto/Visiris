//
//  VSTimelineObjectParametersView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSTimelineObjectParametersView.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectParametersView

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
    [[NSColor greenColor] setFill];
    NSRectFill(dirtyRect);
    
}

-(BOOL) isFlipped{
    return YES;
}

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
}

@end
