//
//  VSAnimationTimelineContentView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineContentView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTimelineContentView

-(void) drawRect:(NSRect)dirtyRect{
    [[NSColor blueColor] setFill];
    
    NSRectFill(dirtyRect);
}

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
}

-(void) setFrameSize:(NSSize)newSize{
    [super setFrameSize:newSize];
}

@end
