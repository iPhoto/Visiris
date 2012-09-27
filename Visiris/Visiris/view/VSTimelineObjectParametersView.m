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

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - NSView

-(BOOL) isFlipped{
    return YES;
}

-(void) drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    [[NSColor redColor] setFill];
    
    NSRectFill(dirtyRect);
}

@end
