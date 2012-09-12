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
        
        if([self.view isKindOfClass:[VSAnimationTimelineView class]]){
            ((VSAnimationTimelineView*) self.view).timelineViewDelegate = self;
        }
    }
    
    return self;
}


-(void) awakeFromNib{
    [super awakeFromNib];
    
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.view setAutoresizesSubviews:YES];
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
    
    [self.view setFrameSize:self.view.superview.frame.size];
    
    if(self.timelineObject){
        for(VSParameter *parameter in [self.timelineObject visibleParameters]){
            
            NSRect trackRect = NSMakeRect(0, self.animationTrackViewControllers.count*self.trackHeight, [self pixelForTimestamp:self.timelineObject.duration], self.trackHeight);
            
            NSColor *trackColor = self.animationTrackViewControllers.count % 2 == 0 ? self.evenTrackColor : self.oddTrackColor;
            
            VSAnimationTrackViewController *animationTrackViewController = [[VSAnimationTrackViewController alloc]initWithFrame:trackRect andColor:trackColor];
            
            [self.animationTrackViewControllers addObject:animationTrackViewController];
            
            [animationTrackViewController.view setFrame:trackRect];
            
            [animationTrackViewController.view setAutoresizingMask:NSViewWidthSizable];
            
            [self.scrollView addTrackView:animationTrackViewController.view];
        }
    }
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
