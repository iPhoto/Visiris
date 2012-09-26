//
//  VSMainTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSMainTimelineScrollView.h"

#import "VSMainTimelineScrollViewDocumentView.h"

#import "VSTrackLabelsRulerView.h"

@interface VSMainTimelineScrollView()

/** Subclass of NSRulerView, displaying information about the tracks at the left side of the timeline */
@property VSTrackLabelsRulerView *trackLabelRulerView;

@end

@implementation VSMainTimelineScrollView

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
    // Drawing code here.
}

-(void) awakeFromNib{
    
    self.trackHolderView = [[VSMainTimelineScrollViewDocumentView alloc] init];
    [super awakeFromNib];
    
    [self initTrackLabelsRuler];
}

-(void) initTrackLabelsRuler{
    self.trackLabelRulerView = [[VSTrackLabelsRulerView alloc] initWithScrollView:self orientation:NSVerticalRuler];
    self.trackLabelRulerView.clientView = self.trackHolderView;
    self.verticalRulerView = self.trackLabelRulerView;
    self.hasVerticalRuler = YES;
    self.rulersVisible = YES;
    [self.verticalRulerView setClientView:self.trackHolderView];
}

#pragma mark - Methods

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel{
    [self.trackLabelRulerView addTrackLabel:aTrackLabel];
}



@end
