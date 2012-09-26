//
//  VSAnimationTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineScrollView.h"

#import "VSAnimationTimelineScrollViewDocumentView.h"

#import "VSCoreServices.h"

@implementation VSAnimationTimelineScrollView

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    if([self.documentView isKindOfClass:[VSAnimationTimelineScrollViewDocumentView class]]){
        self.trackHolderView = ((VSAnimationTimelineScrollViewDocumentView*)self.documentView);
    }
    else{
        self.trackHolderView = [[VSAnimationTimelineScrollViewDocumentView alloc] init];
    }
    [super awakeFromNib];
    
    self.hasVerticalRuler = NO;
    self.hasHorizontalRuler = YES;
    
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self setAutoresizesSubviews:YES];

}

#pragma mark - Methods

-(void) addTrackView:(NSView *)aTrackView{
    [super addTrackView:aTrackView];
    
    float firstSubViewsYPos = [[self.trackHolderView.subviews
                                objectAtIndex:0] frame].origin.y;
    float lastSubViewsMaxY = NSMaxY([[self.trackHolderView.subviews lastObject] frame]);
    
    float totalHeight = lastSubViewsMaxY - firstSubViewsYPos;
    
    [self.trackHolderView setFrameSize:NSMakeSize(self.trackHolderView.frame.size.width, totalHeight)];
}

@end
