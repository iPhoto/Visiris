//
//  VSAnimationTimelineContentView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineContentView.h"

@implementation VSAnimationTimelineContentView

-(void) drawRect:(NSRect)dirtyRect{
    [[NSColor blueColor] setFill];
    
    NSRectFill(dirtyRect);
}

@end
