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

/** Dictionary holding the VSAnimationTrackViewControllers the timeline sets up for its VSTimelineObject. The ID of the VSParameter the different tracks are representing is used as key. The key is neccessary to provide fast queries between the different Parameters and their corresponding tracks. */
@property (strong) NSMutableDictionary *animationTrackViewControllers;

/** Reference of the VSPlayhead of the VSTimeline stored in the current VSDocument */
@property (readwrite, weak) VSPlayHead *playhead;

@end




@implementation VSAnimationTimelineViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSAnimationTimelineView";

@synthesize playhead    = _playhead;

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

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //moves the playheadMarker if the currentPosition of the timelines Playhead has been changed
    if([keyPath isEqualToString:@"currentTimePosition"]){
        double playheadTimestamp = [[object valueForKey:keyPath] doubleValue];
        [self playHeadsCurrentTimePositionHasBeenChangedToTimePosition:playheadTimestamp];
    }
}

#pragma mark - NSResponder

-(void) moveRight:(id)sender{
    [self letPlayheadJumpOverTheDefaultDistanceForward:NO];
}

-(void)moveLeft:(id)sender{
    [self letPlayheadJumpOverTheDefaultDistanceForward:YES];
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
    [self removeSelectedKeyFrames];
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

-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController *)keyFrameViewController wantsToBeDraggedFrom:(NSPoint)fromPoint to:(NSPoint)toPoint onTrack:(VSAnimationTrackViewController *)track{
    
    NSPoint result = toPoint;
    
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(keyFrame:ofParameter:willBeMovedFromTimestamp:toTimestamp:andFromValue:toValue:)]){
        
        //converts the vaues of the NSPoints to timestamps and parameter-values
        double fromTimestamp = [self timestampForPixelValue:fromPoint.x];
        double toTimestamp = [self timestampForPixelValue:toPoint.x];
        
        id fromValue = keyFrameViewController.keyFrame.value;
        id toValue = fromValue;
        
        //if the parameter is a float it's value can be changed by change the y-Position of the its VSKeyFrameView
        if(track.parameter.dataType == VSParameterDataTypeFloat){
            
            toValue = [NSNumber numberWithFloat:[track parameterValueOfPixelPosition:toPoint.y
                                                                         forKeyFrame:keyFrameViewController]];
        }
        
        bool allowedToMove = [self.keyFrameSelectingDelegate keyFrame:keyFrameViewController.keyFrame
                                                          ofParameter:track.parameter
                                             willBeMovedFromTimestamp:fromTimestamp
                                                          toTimestamp:&toTimestamp andFromValue:fromValue toValue:&toValue];
        
        //if the delegate allows to move, a NSPoint is created according to the toValue and the toTimstamp
        if(allowedToMove){
            float newX = [self pixelForTimestamp:toTimestamp];
            float newY = [track pixelPositonForKeyFramesValue:keyFrameViewController];
            
            result = NSMakePoint(newX, newY);
        }
    }
    return result;
}

#pragma mark - Methods


-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject{
    
    if(self.timelineObject){
        if(self.timelineObject != timelineObject){
            [self resetTimeline];
        }
    }
    
    self.timelineObject = timelineObject;
    
    [self initPlayhead];
    
    
    
    if(self.timelineObject){
        
        NSArray *parameters = [self.timelineObject visibleParameters];
        
        float width = self.scrollView.visibleTrackViewsHolderWidth;
        
        for(VSParameter *parameter in parameters){
            
            NSRect trackRect = NSMakeRect(0, self.animationTrackViewControllers.count*self.trackHeight , width, self.trackHeight);
            
            NSColor *trackColor = self.animationTrackViewControllers.count % 2 == 0 ? self.evenTrackColor : self.oddTrackColor;
            
            VSAnimationTrackViewController *animationTrackViewController = [[VSAnimationTrackViewController alloc]initWithFrame:trackRect
                                                                                                                       andColor:trackColor
                                                                                                                   forParameter:parameter
                                                                                                              andPixelTimeRatio:self.pixelTimeRatio];
            
            animationTrackViewController.delegate = self;
            
            [self.animationTrackViewControllers setObject:animationTrackViewController
                                                   forKey:[NSNumber numberWithInteger:parameter.ID]];
            
            [animationTrackViewController.view setFrame:trackRect];
            [animationTrackViewController.view setAutoresizingMask:NSViewWidthSizable];
            
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


#pragma mark - Private Methods

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

/**
 * Removes all VSAnimationTrackViewControllers stored in animaitonTrackViewControllers
 */
-(void) resetTimeline{
    for(VSAnimationTrackViewController *animationTrackViewController in [self.animationTrackViewControllers allValues]){
        [animationTrackViewController.view removeFromSuperview];
    }
    
    [self.animationTrackViewControllers removeAllObjects];
}

/**
 * Asks it's keyFrameSelectinDelegate if it is allowed to delete the currently selected keyFrames. If yes it iterates through all VSAnimationTrackViewController of the VSAnimationTimlineViewController and tells them to remove the selected keyFrames they are responsible for.
 */
-(void) removeSelectedKeyFrames{
    
    BOOL allowedToDelete = YES;
    
    if([self keyFrameSelectingDelegateRespondsToSelector:@selector(selectedKeyFramesWantsBeDeleted)]){
        allowedToDelete = [self.keyFrameSelectingDelegate selectedKeyFramesWantsBeDeleted];
    }
    
    if(allowedToDelete){
        for(VSAnimationTrackViewController *track in [self.animationTrackViewControllers allValues]){
            [track removeSelectedKeyFrames];
        }
        
        //after deleting the keyFrames the currentValues have to be updated
        for (VSParameter *parameter in self.timelineObject.visibleParameters){
            [parameter updateCurrentValueForTimestamp:[super timestampForPixelValue:self.timelineScrollView.playheadMarkerLocation]];
        }
    }
}


#pragma mark Moving ot keyFrame

/**
 * Iterates through all VSAnimationTrackViewController of the VSAnimationTimlineViewController and asks them about their VSKeyFrameViewControllers which are next to the current position of the playhead. Afterwars it finds out which of them are the nearest and moves the playhead to the nearest keyframe.
 */
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

/**
 * Iterates through all VSAnimationTrackViewController of the VSAnimationTimlineViewController and asks them about their VSKeyFrameViewControllers which are next to the current position of the playhead. Afterwars it finds out which of them are the nearest and moves the playhead to the nearest keyframe.
 */
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

#pragma mark Updating parameters' currentValues

/**
 * Iterates throuh all VSParameter of the timelineObject and tells them to update their currentValues according to the given timestamp
 *
 * @param timestamp Timestamp the currentValue is computed for
 */
-(void) updateCurrentParameterValuesAtTimestamp:(double) timestamp{
    for(VSParameter *parameter in self.timelineObject.visibleParameters){
        [parameter updateCurrentValueForTimestamp:timestamp];
    }
}

/**
 * Iterates throuh all VSParameter of the timelineObject and tells them to update their currentValues according to the currentTimePosition of the playhead
 */
-(void) updateCurrentParameterValuesForPlayheadsCurrentTimePosition{
    [self updateCurrentParameterValuesAtTimestamp:[self localTimestampForGlobalTimestamp:self.playhead.currentTimePosition]];
}


#pragma mark Playhead

/**
 * Moves the playhead to the midPoint of the view the given VSKeyFrameViewController is responsible for
 *
 * @param keyFrameViewController The Playhead is moved to midPoint of the view the keyFrameViewController is responsible for
 */
-(void) movePlayheadToKeyFrame:(VSKeyFrameViewController*) keyFrameViewController{
    self.playhead.currentTimePosition = [self globalTimestampForPixelPosition:[VSFrameUtils midPointOfFrame:keyFrameViewController.view.frame].x];
}

/**
 * Stores the playhead of timeline of the current VSDocument and adds an Observer to its currentPosition property
 */
-(void) initPlayhead{
    if(self.playhead){
        [self.playhead removeObserver:self forKeyPath:@"currentTimePosition"];
    }
    
    self.playhead = ((VSDocument*)[[NSDocumentController sharedDocumentController] currentDocument]).timeline.playHead;
    
    [self.playhead addObserver:self
                    forKeyPath:@"currentTimePosition"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
}

/**
 * Converts the given location of the Playhead to a global Timestamp and sets is the currenTimePosition of the playhed
 */
-(void) moveMainPlayheadAccordingToAnimationTimelinesPlayheadLocation:(CGFloat) location{
    self.playhead.currentTimePosition = [self globalTimestampForPixelPosition:location];;
}

/**
 * Called when the currentTimePosition of the playhead has been changed.
 *
 * Computes the pixel position of playheadMarker according to given timePosition and moves the PlayheadMarker to this locaiton. Afterwards the VSKeyFrameViews which are at the new positon of the playhead are set as selected and the currentValues of all parameters are updated.
 */
-(void) playHeadsCurrentTimePositionHasBeenChangedToTimePosition:(double)newTimeposition{
    
    float markerLocation = [self localPlayheadLocationOfGlobaPlayheadTimePosition:newTimeposition];
    
    [self.scrollView movePlayHeadMarkerToLocation:markerLocation];
    
    [self selectKeyFramesAtPlayheadMarkersLocation:markerLocation];
    
    [self updateCurrentParameterValuesForPlayheadsCurrentTimePosition];
}

/**
 * Sets the VSKeyFrameViews which are at the given markerLocation as selected
 *
 * Iterates through its VSAnimationTrackViewController and tells them to return the VSKeyFrameViewController which is at the given markerLocation. Afterwards it informs its keyFrameSelectingDelegate about the selected keyFrames.
 */
-(void) selectKeyFramesAtPlayheadMarkersLocation:(float) markerLocation{
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
}

/**
 * Translates the given timestamp into an pixel-location of the playhead marker
 *
 * @param globalTimePosition Timeposition which is converted to an pixel-location of the playhead marker
 * @return Pixel-location of the playhead marker according to the given timePosition
 */
-(float) localPlayheadLocationOfGlobaPlayheadTimePosition:(double) globalTimePosition{
    double localTimestamp = [self.timelineObject localTimestampOfGlobalTimestamp:globalTimePosition];
    
    float markerLocation = [super pixelForTimestamp:0];
    
    if(localTimestamp != -1){
        markerLocation = [super pixelForTimestamp:localTimestamp];
    }
    else if(globalTimePosition > self.timelineObject.endTime){
        markerLocation = [super pixelForTimestamp:self.timelineObject.duration];
    }
    
    return markerLocation;
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

#pragma mark Translating between pixel postions and timestamps

/**
 * Translates the given globalTimestamp to a local-timestamp of timelineObject
 *
 * @param timestamp Global timestamp to be translated into a local-timestamp of timelineObject
 */
-(double) localTimestampForGlobalTimestamp:(double) timestamp{
    return [self.timelineObject localTimestampOfGlobalTimestamp:timestamp];
}

/**
 * Translates the given globalTimestamp to a pixel position according to the timelienObject relative time and the current pixelTimeRatio.
 *
 * @param timestamp Global timestamp to be translated into a pixel-position.
 */
-(double) pixelForGlobalTimestamp:(double) timestamp{
    return [self pixelForTimestamp:[self.timelineObject localTimestampOfGlobalTimestamp:timestamp]];
}

/**
 * Translates the given pixelPosition into an global Timestamp.
 *
 * @param position Pixel position to be translated into a global timestamp
 */
-(double) globalTimestampForPixelPosition:(double) position{
    return [self.timelineObject globalTimestampOfLocalTimestamp:[self timestampForPixelValue:position]];
}

/**
 * Translates the given pixelPosition into an local Timestamp according to timelineObject's relative time and the current pixelTimeRatio
 *
 * @param position Pixel position to be translated into a local timestamp
 */
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

-(void) setPlayhead:(VSPlayHead *)playhead{
    _playhead = playhead;
}

-(VSPlayHead*) playhead{
    return _playhead;
}

@end
