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
    
    self.hasVerticalRuler = NO;
    self.hasHorizontalRuler = YES;
    
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self setAutoresizesSubviews:YES];
    
    [((NSView*)self.documentView) setAutoresizingMask: NSViewWidthSizable];
}


-(void) addTrackView:(NSView *)aTrackView{
    [super addTrackView:aTrackView];
    
    float firstSubViewsYPos = [[self.trackHolderView.subviews
                                objectAtIndex:0] frame].origin.y;
    float lastSubViewsMaxY = NSMaxY([[self.trackHolderView.subviews lastObject] frame]);
    
    float totalHeight = lastSubViewsMaxY - firstSubViewsYPos;
    
    [self.trackHolderView setFrameSize:NSMakeSize(self.trackHolderView.frame.size.width, totalHeight)];
}

#pragma mark - Properties

@end
