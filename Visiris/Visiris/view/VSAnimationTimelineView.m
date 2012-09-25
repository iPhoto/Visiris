//
//  VSAnimationTimelineView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineView.h"

#import "VSCoreServices.h"

@interface VSAnimationTimelineView()



@end

@implementation VSAnimationTimelineView



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}




-(void) mouseEntered:(NSEvent *)theEvent{
    [self.window makeFirstResponder:self];
}

@end
