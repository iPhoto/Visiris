//
//  VSAnimationTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineScrollView.h"

#import "VSAnimationTimelineContentView.h"

#import "VSCoreServices.h"                      

@implementation VSAnimationTimelineScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    if([self.documentView isKindOfClass:[VSAnimationTimelineContentView class]]){
        self.trackHolderView = ((VSAnimationTimelineContentView*)self.documentView);
    }
    else{
        self.trackHolderView = [[VSAnimationTimelineContentView alloc] init];
    }   
    [super awakeFromNib];
    
    [self.trackHolderView setAutoresizingMask:NSViewWidthSizable];
    
    self.hasVerticalRuler = NO;
    self.hasHorizontalRuler = YES;
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void) scrollWheel:(NSEvent *)theEvent{
    [[self nextResponder] scrollWheel:theEvent];
    
    if(theEvent.deltaY == 0.0){
        [super scrollWheel:theEvent];
    }
    
}

-(void) addTrackView:(NSView *)aTrackView{
    [super addTrackView:aTrackView];
    
    [self.trackHolderView setFrameSize:NSMakeSize(self.documentVisibleRect.size.width, self.trackHolderView.frame.size.height)];
}

#pragma mark - Properties

@end
