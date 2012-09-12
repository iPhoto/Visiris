//
//  VSAnimationTimelineViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTimelineViewController.h"

#import "VSTimelineObject.h"
#import "VSParameter.h"
#import "VSAnimationTimelineScrollView.h"
#import "VSAnimationTrackViewController.h"
#import "VSAnimationTimelineView.h"

#import "VSCoreServices.h"

@interface VSAnimationTimelineViewController ()

@property VSTimelineObject *timelineObject;

@property float trackHeight;

@property NSMutableArray *animationTrackViewControllers;

@end

@implementation VSAnimationTimelineViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
@synthesize scrollView = _scrollView;
static NSString* defaultNib = @"VSAnimationTimelineView";


#pragma mark - Init

-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight{
    if(self = [super initWithNibName:defaultNib bundle:nil]){
        self.animationTrackViewControllers = [[NSMutableArray alloc]init];
        self.trackHeight = trackHeight;
    }
    
    return self;
}


-(void) awakeFromNib{
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.view setAutoresizesSubviews:YES];
    
    [super awakeFromNib];
    
//    ((VSAnimationTimelineView*)self.view).resizingDelegate = nil;
}

#pragma mark - VSPlayHeadRulerMarkerDelegate Implementation

-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    return YES;
}

-(void) didMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{

}

-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView toLocation:(CGFloat)location{

    return location;
}

-(CGFloat) playHeadRulerMarker:(NSRulerMarker *)playheadMarker willJumpInContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    return location;
}

#pragma mark - Methods

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject{
    
    if(self.timelineObject){
        if(self.timelineObject != timelineObject){
            [self resetTimeline];
        }
    }
    
    self.timelineObject = timelineObject;
    
    [self computePixelTimeRatio];
    DDLogInfo(@"pixelTimeRati: %f",self.pixelTimeRatio);
    [self.view setFrameSize:self.view.superview.frame.size];
    
    if(self.timelineObject){
        
        [self.scrollView setTrackHolderWidth:self.scrollView.documentVisibleRect.size.width];
        
        for(VSParameter *parameter in [self.timelineObject visibleParameters]){
            
            
            float width = self.scrollView.visibleTrackViewsHolderWidth;
            
            NSRect trackRect = NSMakeRect(0, self.animationTrackViewControllers.count*self.trackHeight , width, self.trackHeight);
            
            NSColor *trackColor = self.animationTrackViewControllers.count % 2 == 0 ? self.evenTrackColor : self.oddTrackColor;
            
            VSAnimationTrackViewController *animationTrackViewController = [[VSAnimationTrackViewController alloc]initWithFrame:trackRect andColor:trackColor];
            
            [self.animationTrackViewControllers addObject:animationTrackViewController];
            
            [animationTrackViewController.view setFrame:trackRect];
            
            [animationTrackViewController.view setAutoresizingMask:NSViewWidthSizable];
            
            [animationTrackViewController.view setFrame:trackRect];
            
            [self.scrollView addTrackView:animationTrackViewController.view];
        }
    }
    
    NSSize newSize = self.scrollView.trackHolderView.frame.size;
    newSize.width = self.scrollView.documentVisibleRect.size.width;
    
    [self.scrollView.trackHolderView setFrameSize:newSize];
    [self computePixelTimeRatio];
    
   // ((VSAnimationTimelineView*)self.view).resizingDelegate = self;
}

-(void) resetTimeline{
    for(VSAnimationTrackViewController *animationTrackViewController in self.animationTrackViewControllers){
        [animationTrackViewController.view removeFromSuperview];
    }
    
    [self.animationTrackViewControllers removeAllObjects];
}

#pragma mark - Properties

-(double) duration{
    return self.timelineObject.duration;
}

-(float) pixelLength{
    return self.scrollView.trackHolderWidth;
}

-(VSTimelineScrollView*) timelineScrollView{
    return self.scrollView;
}

-(double) playheadTimePosition{
    return [self timestampForPixelValue: self.scrollView.playheadMarkerLocation];
}

@end
