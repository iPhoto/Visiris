//
//  VSTimelineObjectPropertiesControllerViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectPropertiesViewController.h"

#import "VSTimelineObject.h"
#import "VSTimelineObjectParametersViewController.h"
#import "VSTimelineObjectSource.h"
#import "VSParameter.h"
#import "VSTestView.h"
#import "VSTimelineObjectPropertiesView.h"
#import "VSAnimationTimelineViewController.h"
#import "VSAnimationTimelineScrollView.h"
#import "VSAnimationTimelineScrollViewDocumentView.h"
#import "VSKeyFrame.h"
#import "VSPlayhead.h"
#import "VSCoreServices.h"

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

@property (strong) VSAnimationTimelineViewController *animationTimelineViewController;

@property (strong) VSTimelineObjectParametersViewController *parametersViewController;

@property int numberOfParameters;

@end

@implementation VSTimelineObjectPropertiesViewController

/** Height of the parameter views */
#define PARAMETER_VIEW_HEIGHT 70
#define PARAMETER_VIEW_MINIMUM_WIDTH 150
#define PARAMETER_VIEW_MAXIMUM_WIDTH 200

@synthesize splitView                   = _splitView;
@synthesize parametersHolder            = _parametersHolder;
@synthesize animationTimelineHolder     = _animationTimelineHolder;
@synthesize timelineObject              = _timelineObject;
@synthesize nameLabel                   = _nameLabel;
@synthesize nameTextField               = _nameTextField;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectPropertiesView";


#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        
        
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) awakeFromNib{
    [super awakeFromNib];
    
    if([self.view isKindOfClass:[VSTimelineObjectPropertiesView class] ]){
        ((VSTimelineObjectPropertiesView*) self.view).resizingDelegate = self;
    }
    
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.splitView setAutoresizesSubviews:YES];
    
    [self initAnimationTimeline];
    
    [self initParameterView];
    
    [self animationTimelineHolder];
}

/**
 * Instantiates a VSAnimationTimelineViewController, stores its view as subView of animationTimelineHolder and sets the view's properties
 */
-(void) initAnimationTimeline{
    [self.animationTimelineHolder setAutoresizesSubviews:YES];
    [self.animationTimelineHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    float width = self.view.frame.size.width - PARAMETER_VIEW_MINIMUM_WIDTH - self.splitView.dividerThickness;
    
    [self.animationTimelineHolder setFrameSize:NSMakeSize(width, self.view.frame.size.height)];
    
    self.animationTimelineViewController = [[VSAnimationTimelineViewController alloc]initWithDefaultNibAndTrackHeight:PARAMETER_VIEW_HEIGHT];
    
    [self.animationTimelineHolder addSubview:self.animationTimelineViewController.view];
    
    [self.animationTimelineViewController.view setFrameSize:self.animationTimelineHolder.frame.size];
    
    [self.animationTimelineViewController.view setAutoresizesSubviews:YES];
    [self.animationTimelineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.animationTimelineViewController.oddTrackColor = [NSColor lightGrayColor];
    self.animationTimelineViewController.evenTrackColor = [NSColor darkGrayColor];
    
    
    self.animationTimelineViewController.keyFrameSelectingDelegate = self;
    self.animationTimelineViewController.scrollView.scrollingDelegate = self;
    
}

/**
 * Instantiates a VSTimelineObjectParametersViewController, stores its view as subView of parametersHolder and sets the view's properties
 */
-(void) initParameterView{
    [self.parametersHolder setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask: NSViewWidthSizable];
    [self.parametersHolder setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersHolder.frame.size.height)];
    
    self.parametersViewController = [[VSTimelineObjectParametersViewController alloc] initWithDefaultNibAndParameterViewHeight:PARAMETER_VIEW_HEIGHT];
    
    self.parametersViewController.oddColor = [NSColor lightGrayColor];
    self.parametersViewController.evenColor = [NSColor darkGrayColor];
    
    [self.parametersHolder addSubview:self.parametersViewController.view];
    
    [self.parametersViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.parametersViewController.view setAutoresizesSubviews:YES];
    
    float yOffset =self.animationTimelineViewController.scrollView.horizontalRulerView.frame.size.height;
    NSRect parametersViewFrame = self.parametersHolder.frame;
    
    parametersViewFrame.size.height -= yOffset;
    parametersViewFrame.origin.x = 0;
    parametersViewFrame.origin.y = yOffset;
    
    [self.parametersViewController.view setFrame:parametersViewFrame];
    
    
    
    NSString *constraintString = [NSString stringWithFormat:@"V:|-%f-[parameterView]|", yOffset];
    
    //  [self.parametersHolder removeConstraints:self.parametersHolder.constraints];
    
    [self.parametersHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:[NSDictionary dictionaryWithObject:self.parametersViewController.view forKey:@"parameterView"]]];
    
    [self.parametersHolder addConstraint:[NSLayoutConstraint constraintWithItem:self.parametersViewController.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.parametersHolder
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0 constant:yOffset*(-1)]];
    
    
    self.parametersViewController.scrollView.scrollingDelegate = self;
    
}

-(void) willBeHidden{
    [self.animationTimelineViewController resetTimeline];
    [self.parametersViewController resetParameters];
    self.timelineObject = nil;
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"name"]) {
        [self.nameTextField setStringValue:[object valueForKey:keyPath]];
    }
}

#pragma mark - VSParameterViewKeyFrameDelegate Implementation

-(VSKeyFrame*) addKeyFrameToParameter:(VSParameter *)parameter withValue:(id)value{
     return [parameter addKeyFrameWithValue:value forTimestamp:self.animationTimelineViewController.playheadTimePosition];
}

-(void) parameterViewController:(VSParameterViewController *)parameterView wantsPlayheadToGoToNextKeyFrameOfParameter:(VSParameter *)parameter{
    [self.animationTimelineViewController moveToNearestKeyFrameRightOfParameter:parameter];
}

-(void) parameterViewController:(VSParameterViewController *)parameterView wantsPlayheadToGoToPreviousFrameOfParameter:(VSParameter *)parameter{
    
    [self.animationTimelineViewController moveToNearestKeyFrameLeftOfParameter:parameter];
}


#pragma mark - VSKeyFrameSelectingDelegate Implementation

-(void) playheadIsOverKeyFrame:(VSKeyFrame *)keyFrame ofParameter:(VSParameter *)paramter{
    [self.parametersViewController selectKeyFrame:keyFrame ofParameter:paramter];
}

-(BOOL) wantToSelectKeyFrame:(VSKeyFrame*) keyFrame ofParamater:(VSParameter *)parameter{
    self.animationTimelineViewController.playhead.currentTimePosition = [self.timelineObject globalTimestampOfLocalTimestamp:keyFrame.timestamp];
    return YES;
}

-(BOOL) keyFrame:(VSKeyFrame *)keyFrame ofParameter:(VSParameter *)parameter willBeMovedFromTimestamp:(double)fromTimestamp toTimestamp:(double *)toTimestamp andFromValue:(id)fromValue toValue:(__autoreleasing id *)toValue{
    
    [parameter changeKeyFrames:keyFrame timestamp:*toTimestamp];
    keyFrame.value = *toValue;
    
    [parameter updateCurrentValueForTimestamp:self.animationTimelineViewController.playhead.currentTimePosition];
    
    return YES;
}

-(BOOL) selectedKeyFramesWantsBeDeleted{
    [self.parametersViewController unselectAllSelectedKeyFrames];
    
    return YES;
}

#pragma mark - VSScrollViewScrollingDelegate Implementation

-(void) scrollView:(NSScrollView *)scrollView changedBoundsFrom:(NSRect)fromBounds to:(NSRect)toBounds{
    
    VSScrollView *scrollViewToScroll = nil;
    
    if([scrollView isEqual:self.animationTimelineViewController.scrollView]){
        scrollViewToScroll = self.parametersViewController.scrollView;
    }
    else if([scrollView isEqual:self.parametersViewController.scrollView]){
        scrollViewToScroll = self.animationTimelineViewController.scrollView;
    }
    
    if(scrollViewToScroll){
        NSPoint newBoundsOrigin = NSMakePoint(scrollViewToScroll.contentView.bounds.origin.x, toBounds.origin.y);
        
        [scrollViewToScroll setBoundsOriginWithouthNotifiying:newBoundsOrigin];
        
    }
    

}

#pragma mark - Private Methods


/**
 * Changes the paramters name
 * @param newName Name the the VSTimelineObject's name will be changed to
 */
-(void) setTimelineObjectName:(NSString*)newName{
    if(![self.timelineObject.name isEqualToString:newName]){
        [self.timelineObject changeName:newName andRegisterAt:self.view.undoManager];
    }
}

/**
 * Tells the parametersViewController to show the parameters of the timelineObject 
 */
-(void) showParameters{
    [self.parametersViewController showParametersOfTimelineObject:self.timelineObject connectedWithDelegate:self];
    NSSize newSize = [self.parametersViewController.scrollView.documentView frame].size;
    
    newSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    
    [self.parametersViewController.scrollView.documentView setFrameSize:newSize];
}

/**
 * Tells the animationTimelineViewController to show the the animationTimeline of the timelineObject
 */
-(void) showAnimationTimeline{
    [self.animationTimelineViewController showTimelineForTimelineObject:self.timelineObject];
}

#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        
        
        if(_timelineObject){
            //[self.timelineObject removeObserver:self forKeyPath:@"name"];
            [self setTimelineObjectName:[self.nameTextField stringValue]];
            [self.parametersViewController resetParameters];
            
        }
        
        _timelineObject = timelineObject;
        
        self.numberOfParameters = [timelineObject visibleParameters].count;

        [self showParameters];
        
        [self showAnimationTimeline];
        
        [self.animationTimelineViewController.scrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
        [self.parametersViewController.scrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
        
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}


@end
