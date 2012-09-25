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

@property (strong) NSMutableDictionary *animationTrackViewControllers;

@end

@implementation VSAnimationTimelineViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
@synthesize scrollView = _scrollView;
static NSString* defaultNib = @"VSAnimationTimelineView";


#pragma mark - Init

-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight{
    if(self = [super initWithNibName:defaultNib bundle:nil]){
        self.animationTrackViewControllers = [[NSMutableDictionary alloc]init];
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
        [self playHeadsCurrentTimePositionHasBeenChanged:playheadTimestamp];
    }
}

-(void) moveMainPlayheadAccordingToAnimationTimelinesPlayheadLocation:(CGFloat) location{
    double newTimePosition = [super timestampForPixelValue:location];
    double globalTimePosition = [self.timelineObject globalTimestampOfLocalTimestamp:newTimePosition];
    
    self.playhead.currentTimePosition = globalTimePosition;
}

#pragma mark - NSResponder

-(void) moveRight:(id)sender{
    
}

-(void)moveLeft:(id)sender{
}

-(void) moveWordRight:(id) sender{
    [self moveToNearestKeyFrameRight];
}

-(void) moveWordLeft:(id)sender{
    [self moveToNearestKeyFrameLeft];
}

-(void) deleteForward:(id)sender{
    [self removeSelectedKeyFrames];
}

-(void)deleteBackward:(id)sender{
    [self removeSelectedKeyFrames];
}

-(void) deleteToBeginningOfLine:(id)sender{
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
        for(VSAnimationTrackViewController *animationTrackViewController in [self.animationTrackViewControllers allValues]){
            [animationTrackViewController unselectAllKeyFrames];
        }
    }
    
    return result;
}

//TODO: sending changend values
-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController *)keyFrameViewController wantsToBeDraggedFrom:(NSPoint)fromPoint to:(NSPoint)toPoint onTrack:(VSAnimationTrackViewController *)track{
    
    NSPoint result = toPoint;
    
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(keyFrame:ofParameter:willBeMovedFromTimestamp:toTimestamp:andFromValue:toValue:)]){
        
        double fromTimestamp = [self timestampForPixelValue:fromPoint.x];
        double toTimestamp = [self timestampForPixelValue:toPoint.x];
        
        id fromValue = keyFrameViewController.keyFrame.value;
        id toValue = fromValue;
        
        if(track.parameter.dataType == VSParameterDataTypeFloat){
            toValue = [NSNumber numberWithFloat:[track parameterValueOfPixelPosition:toPoint.y forKeyFrame:keyFrameViewController]];
        }
        
        bool allowedToMove = [self.keyFrameSelectingDelegate keyFrame:keyFrameViewController.keyFrame
                                                          ofParameter:track.parameter
                                             willBeMovedFromTimestamp:fromTimestamp
                                                          toTimestamp:&toTimestamp andFromValue:fromValue toValue:&toValue];
        
        if(allowedToMove){
            float newX = [self pixelForTimestamp:toTimestamp];
            float newY = [track pixelPositonForKeyFramesValue:keyFrameViewController];
            
            result = NSMakePoint(newX, newY);
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
    for(VSAnimationTimelineViewController *animationTrackViewController in [self.animationTrackViewControllers allValues]){
        animationTrackViewController.pixelTimeRatio = self.pixelTimeRatio;
    }
}

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject{
    
    if(self.timelineObject){
        if(self.timelineObject != timelineObject){
            [self resetTimeline];
        }
    }
    
    if(self.playhead){
        [self.playhead removeObserver:self forKeyPath:@"currentTimePosition"];
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
            
            [self.animationTrackViewControllers setObject:animationTrackViewController forKeyedSubscript:[NSNumber numberWithInteger:parameter.ID]];
            
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

-(VSAnimationTrackViewController *) trackViewControllerOfParameter:(VSParameter *) parameter{
    return [self.animationTrackViewControllers objectForKey:[NSNumber numberWithInteger:parameter.ID]];
}

-(void) moveToNearestKeyFrameLeftOfParameter:(VSParameter*) parameter{
    VSAnimationTrackViewController *animationTrackViewController = [self trackViewControllerOfParameter:parameter];
    
    if(animationTrackViewController){
        VSKeyFrameViewController *nearestKeyFrameViewController = [animationTrackViewController nearestKeyFrameViewLeftOfXPosition:[self currentPlayheadMarkerLocation]];
        
        if(nearestKeyFrameViewController){
            [self movePlayheadToKeyFrame:nearestKeyFrameViewController];
        }
    }
}

-(void) moveToNearestKeyFrameRightOfParameter:(VSParameter*) parameter{
    VSAnimationTrackViewController *animationTrackViewController = [self trackViewControllerOfParameter:parameter];
    
    if(animationTrackViewController){
        VSKeyFrameViewController *nearestKeyFrameViewController = [animationTrackViewController nearestKeyFrameViewRightOfXPosition:[self currentPlayheadMarkerLocation]];
        
        if(nearestKeyFrameViewController){
            [self movePlayheadToKeyFrame:nearestKeyFrameViewController];
        }
    }
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
    for(VSAnimationTrackViewController *animationTrackViewController in [self.animationTrackViewControllers allValues]){
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

#pragma mark - Private Methods

-(void) moveToNearestKeyFrameLeft{
    
    float xPosition = [self currentPlayheadMarkerLocation];
    
    VSKeyFrameViewController *nearestKeyFrameViewController = nil;
    
    for(VSAnimationTrackViewController *trackViewController in [self.animationTrackViewControllers allValues]){
        VSKeyFrameViewController *nearestKeyFrameViewControllerOfTrack = [trackViewController nearestKeyFrameViewLeftOfXPosition:xPosition];
        
        if(nearestKeyFrameViewControllerOfTrack){
            if(nearestKeyFrameViewController){
                if(nearestKeyFrameViewControllerOfTrack.view.frame.origin.x > nearestKeyFrameViewController.view.frame.origin.x){
                    nearestKeyFrameViewController = nearestKeyFrameViewControllerOfTrack;
                }
            }
            else{
                nearestKeyFrameViewController = nearestKeyFrameViewControllerOfTrack;
            }
        }
    }
    
    if(nearestKeyFrameViewController){
        [self movePlayheadToKeyFrame:nearestKeyFrameViewController];
    }
}


-(void) moveToNearestKeyFrameRight{
    
    float xPosition = [self currentPlayheadMarkerLocation];
    
    VSKeyFrameViewController *nearestKeyFrameViewController = nil;
    
    for(VSAnimationTrackViewController *trackViewController in [self.animationTrackViewControllers allValues]){
        VSKeyFrameViewController *nearestKeyFrameViewControllerOfTrack = [trackViewController nearestKeyFrameViewRightOfXPosition:xPosition];
        
        if(nearestKeyFrameViewControllerOfTrack){
            if(nearestKeyFrameViewController){
                if(nearestKeyFrameViewControllerOfTrack.view.frame.origin.x < nearestKeyFrameViewController.view.frame.origin.x){
                    nearestKeyFrameViewController = nearestKeyFrameViewControllerOfTrack;
                }
            }
            else{
                nearestKeyFrameViewController = nearestKeyFrameViewControllerOfTrack;
            }
        }
    }
    
    if(nearestKeyFrameViewController){
        [self movePlayheadToKeyFrame:nearestKeyFrameViewController];
    }
}

-(void) movePlayheadToKeyFrame:(VSKeyFrameViewController*) keyFrameViewController{
    self.playhead.currentTimePosition = [self globalTimestampForPixelPosition:[VSFrameUtils midPointOfFrame:keyFrameViewController.view.frame].x];
}

-(void) removeSelectedKeyFrames{
    
    BOOL allowedToDelete = YES;
    
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(selectedKeyFramesWantsBeDeleted)]){
        allowedToDelete = [self.keyFrameSelectingDelegate selectedKeyFramesWantsBeDeleted];
    }
    
    if(allowedToDelete){
        for(VSAnimationTrackViewController *track in [self.animationTrackViewControllers allValues]){
            [track removeSelectedKeyFrames];
        }
        
        for (VSParameter *parameter in self.timelineObject.visibleParameters){
            [parameter updateCurrentValueForTimestamp:[super timestampForPixelValue:self.timelineScrollView.playheadMarkerLocation]];
        }
    }
}

#pragma mark Playhead

-(void) playHeadsCurrentTimePositionHasBeenChanged:(double)newTimeposition{
    
    double localTimestamp = [self.timelineObject localTimestampOfGlobalTimestamp:newTimeposition];
    
    float markerLocation = [super pixelForTimestamp:0];
    
    if(localTimestamp != -1){
        markerLocation = [super pixelForTimestamp:localTimestamp];
    }
    else if(newTimeposition > self.timelineObject.endTime){
        markerLocation = [super pixelForTimestamp:self.timelineObject.duration];
    }
    
    [self.scrollView movePlayHeadMarkerToLocation:markerLocation];
    
    
    
    for(VSAnimationTrackViewController *trackViewController in [self.animationTrackViewControllers allValues]){

        [trackViewController unselectAllKeyFrames];
        
        VSKeyFrameViewController *keyFrameViewController = [trackViewController keyFrameViewControllerAtXPosition:markerLocation];
        
        VSKeyFrame *selectedKeyFrame = nil;
        
        if(keyFrameViewController){
            selectedKeyFrame = keyFrameViewController.keyFrame;
        }
        if([self keyFrameSelectingDelegateRespondsToSelector:@selector(playheadIsOverKeyFrame:ofParameter:)]){
            [self.keyFrameSelectingDelegate playheadIsOverKeyFrame:selectedKeyFrame
                                                       ofParameter:trackViewController.parameter];
            
            keyFrameViewController.selected = YES;
        }
    }
    
    [self updateCurrentParameterValuesAtTimestamp:localTimestamp];
}

-(void) updateCurrentParameterValuesAtTimestamp:(double) timestamp{
    for(VSParameter *parameter in self.timelineObject.visibleParameters){
        [parameter updateCurrentValueForTimestamp:timestamp];
    }
}
/**
 * Sets the plahead marker according to the playhead's currentposition on the timeline
 */
-(void) setPlayheadMarkerLocation{
    CGFloat newLocation = [self pixelForGlobalTimestamp:self.playhead.currentTimePosition];
    
    [self.scrollView movePlayHeadMarkerToLocation:newLocation];
}

/**
 * Returns the current Location of the Playhead Marker
 * @return current location of the PlayheadMarker
 */
-(float) currentPlayheadMarkerLocation{
    return self.scrollView.playheadMarkerLocation;
}


-(double) pixelForGlobalTimestamp:(double) timestamp{
    return [self pixelForTimestamp:[self.timelineObject localTimestampOfGlobalTimestamp:timestamp]];
}

-(double) globalTimestampForPixelPosition:(double) position{
    return [self.timelineObject globalTimestampOfLocalTimestamp:[self timestampForPixelValue:position]];
}

-(double) localTimestampForPixelPosition:(double) position{
    return [self.timelineObject localTimestampOfGlobalTimestamp:[self timestampForPixelValue:position]];
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
