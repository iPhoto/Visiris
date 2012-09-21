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
#import "VSTimeline.h"
#import "VSDocument.h"
#import "VSPlayhead.h"
#import "VSKeyFrameViewController.h"
#import "VSParameter.h"
#import "VSKeyFrame.h"

#import "VSCoreServices.h"

@interface VSAnimationTimelineViewController ()

@property (weak) VSTimelineObject*timelineObject;

@property float trackHeight;

@property (strong) NSMutableArray *animationTrackViewControllers;

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
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //moves the playheadMarker if the currentPosition of the timelines Playhead has been changed
    if([keyPath isEqualToString:@"currentTimePosition"]){
        double playheadTimestamp = [[object valueForKey:keyPath] doubleValue];
        double localTimestamp = [self.timelineObject localTimestampOfGlobalTimestamp:playheadTimestamp];
        
        float markerLocation = [super pixelForTimestamp:0];
        
        if(localTimestamp != -1){
            markerLocation = [super pixelForTimestamp:localTimestamp];
            
        }
        else if(playheadTimestamp > self.timelineObject.endTime){
            markerLocation = [super pixelForTimestamp:self.timelineObject.duration];
        }
        
        [self.scrollView movePlayHeadMarkerToLocation:markerLocation];
        
        for(VSParameter *parameter in self.timelineObject.visibleParameters){
            [parameter updateCurrentValueForTimestamp:localTimestamp];
        }
        
        for(VSAnimationTrackViewController *trackViewController in self.animationTrackViewControllers){
            VSKeyFrameViewController *keyFrameViewController = [trackViewController keyFrameViewControllerAtXPosition:markerLocation];
            
            VSKeyFrame *selectedKeyFrame = nil;
            
            if(keyFrameViewController){
                selectedKeyFrame = keyFrameViewController.keyFrame;
            }
            if([self keyFrameSelectingDelegateRespondsToSelector:@selector(playheadIsOverKeyFrame:ofParameter:)]){
                
                [self.keyFrameSelectingDelegate playheadIsOverKeyFrame:selectedKeyFrame
                                                           ofParameter:trackViewController.parameter];
            }
        }
    }
}

-(void) moveMainPlayheadAccordingToAnimationTimelinesPlayheadLocation:(CGFloat) location{
    double newTimePosition = [super timestampForPixelValue:location];
    double globalTimePosition = [self.timelineObject globalTimestampOfLocalTimestamp:newTimePosition];
    
    self.playhead.currentTimePosition = globalTimePosition;
}

#pragma mark - VSPlayHeadRulerMarkerDelegate Implementation

-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    return YES;
}

-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    [self moveMainPlayheadAccordingToAnimationTimelinesPlayheadLocation:location];
    
    return location;
}

-(CGFloat) playHeadRulerMarker:(NSRulerMarker *)playheadMarker willJumpInContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    [self moveMainPlayheadAccordingToAnimationTimelinesPlayheadLocation:location];
    
    return location;
}

#pragma mark - VSAnimationTrackViewController

-(BOOL) keyFrameViewController:(VSKeyFrameViewController *)keyFrameViewController wantsToBeSelectedOnTrack:(VSAnimationTrackViewController *)track{
    BOOL result = false;
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(wantToSelectKeyFrame:ofParamater:)]){
        result = [self.keyFrameSelectingDelegate wantToSelectKeyFrame:keyFrameViewController.keyFrame
                                                          ofParamater:track.parameter];
    }
    
    if(result){
        for(VSAnimationTrackViewController *animationTrackViewController in self.animationTrackViewControllers){
            [animationTrackViewController unselectAllKeyFrames];
        }
    }
    
    return result;
}

//TODO: sending changend values
-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController *)keyFrameViewController wantsToBeDraggeFrom:(NSPoint)fromPoint to:(NSPoint)toPoint onTrack:(VSAnimationTrackViewController *)track{
    
    NSPoint result = toPoint;
    
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(keyFrame:ofParameter:willBeMovedFromTimestamp:toTimestamp:andFromValue:toValue:)]){
        
        double fromTimestamp = [self timestampForPixelValue:fromPoint.x];
        double toTimestamp = [self timestampForPixelValue:toPoint.x];
        
        id fromValue = keyFrameViewController.keyFrame.value;
        id toValue = fromValue;
        
        bool allowedToMove = [self.keyFrameSelectingDelegate keyFrame:keyFrameViewController.keyFrame
                                                          ofParameter:track.parameter
                                             willBeMovedFromTimestamp:fromTimestamp
                                                          toTimestamp:&toTimestamp andFromValue:fromValue toValue:&toValue];
        
        if(allowedToMove){
            float newX = [self pixelForTimestamp:toTimestamp];
            result = NSMakePoint(newX, fromPoint.y);
        }
    }
    return result;
}

#pragma mark - Methods

/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange{
    
    [super pixelTimeRatioDidChange];
    
    //tells all VSTrackViewControlls in the timeline, that the pixelItemRation has been changed
    for(VSAnimationTimelineViewController *animationTrackViewController in self.animationTrackViewControllers){
        animationTrackViewController.pixelTimeRatio = self.pixelTimeRatio;
    }
}

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject{
    
    if(self.timelineObject){
        if(self.timelineObject != timelineObject){
            [self resetTimeline];
        }
    }
    
    self.playhead = ((VSDocument*)[[NSDocumentController sharedDocumentController] currentDocument]).timeline.playHead;
    
    [self.playhead addObserver:self
                    forKeyPath:@"currentTimePosition"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    
    self.timelineObject = timelineObject;
    
    if(self.timelineObject){
        
        NSArray *parameters = [self.timelineObject visibleParameters];
        
        for(VSParameter *parameter in parameters){
            float width = self.scrollView.visibleTrackViewsHolderWidth;
            
            NSRect trackRect = NSMakeRect(0, self.animationTrackViewControllers.count*self.trackHeight , width, self.trackHeight);
            
            NSColor *trackColor = self.animationTrackViewControllers.count % 2 == 0 ? self.evenTrackColor : self.oddTrackColor;
            
            VSAnimationTrackViewController *animationTrackViewController = [[VSAnimationTrackViewController alloc]
                                                                            initWithFrame:trackRect                                           andColor:trackColor                forParameter:parameter
                                                                            andPixelTimeRatio:self.pixelTimeRatio];
            
            animationTrackViewController.delegate = self;
            
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
}

#pragma mark- VSViewResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    
    if(newRect.size.width != 0){
        [self computePixelTimeRatio];
        //        if(oldRect.size.width != newRect.size.width){
        //
        //            NSRect newDocumentFrame = [self.timelineScrollView.trackHolderView frame];
        //
        //            //updates the width according to how the width of the view has been resized
        //            newDocumentFrame.size.width += newRect.size.width - oldRect.size.width;
        //            [self.timelineScrollView.trackHolderView setFrame:(newDocumentFrame)];
        //            [self computePixelTimeRatio];
        //        }
    }
}

-(void) resetTimeline{
    for(VSAnimationTrackViewController *animationTrackViewController in self.animationTrackViewControllers){
        [animationTrackViewController.view removeFromSuperview];
    }
    
    [self.animationTrackViewControllers removeAllObjects];
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) keyFrameSelectingDelegateRespondsToSelector:(SEL) selector{
    if(self.keyFrameSelectingDelegate != nil){
        if([self.keyFrameSelectingDelegate conformsToProtocol:@protocol(VSKeyFrameEditingDelegate) ]){
            if([self.keyFrameSelectingDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
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
