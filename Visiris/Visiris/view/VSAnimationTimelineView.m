//
//  VSAnimationTimelineView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTimelineView



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - NSView

-(void) drawRect:(NSRect)dirtyRect{
    DDLogInfo(@"drawREct");
}


@end
