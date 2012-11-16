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
#import "VSDisclosureView.h"
#import "VSTimelineObjectDevicesViewController.h"
#import "VSEmtpyRuler.h"

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

/** Takes care for displaying a VSAnimationTimelineView for every parameter of the VSTimelineObject */
@property (strong) VSAnimationTimelineViewController *animationTimelineViewController;

/** Takes care for displaying a VSParameterView for every parameter of the VSTimelineObject */
@property (strong) VSTimelineObjectParametersViewController *parametersViewController;

/** Takes care for displaying a VSTimelineObjectDevicesView for every device of the VSTimelineObject */
@property (strong) VSTimelineObjectDevicesViewController *timelineObjectDevicesViewController;

@end

@implementation VSTimelineObjectPropertiesViewController

@synthesize timelineObject = _timelineObject;

/** Height of the parameter views */
#define PARAMETER_VIEW_HEIGHT 70

/** Height of the device views */
#define DEVICE_VIEW_HEIGHT 50


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

    
    [self.parametersHolderSplitView setAutoresizingMask:NSViewWidthSizable];
    [self.parametersHolderSplitView setAutoresizesSubviews:NO];
    
    
    [self initAnimationTimeline];
    
    /** inits the properties view and the devices view */
    [self initLeftScrollView];
    
    /** inits the animation timeline */
    [self animationTimelineHolder];
    
    /** observes if the scroller style was changed while showing the properties */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollerStyleDidChange:)
                                                 name:NSPreferredScrollerStyleDidChangeNotification
                                               object:nil];
}


/**
 * Instantiates a VSAnimationTimelineViewController, stores its view as subView of animationTimelineHolder and sets the view's properties
 */
-(void) initAnimationTimeline{
    [self.animationTimelineHolder setAutoresizesSubviews:YES];
    [self.animationTimelineHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    float width = self.view.frame.size.width - self.parametersHolderSplitView.dividerThickness;
    
    [self.animationTimelineHolder setFrameSize:NSMakeSize(width, self.view.frame.size.height)];
    
    self.animationTimelineViewController = [[VSAnimationTimelineViewController alloc]initWithDefaultNibAndTrackHeight:PARAMETER_VIEW_HEIGHT
                                                                                                 andMarginTop:self.parametersDisclosureView.controlAreaHeight];
    
    [self.animationTimelineHolder addSubview:self.animationTimelineViewController.view];
    
    [self.animationTimelineViewController.view setFrameSize:self.animationTimelineHolder.frame.size];
    
    [self.animationTimelineViewController.view setAutoresizesSubviews:YES];
    [self.animationTimelineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    /** sets the color for the tracks */
    self.animationTimelineViewController.oddTrackColor = [NSColor lightGrayColor];
    self.animationTimelineViewController.evenTrackColor = [NSColor darkGrayColor];
    
    self.animationTimelineViewController.keyFrameSelectingDelegate = self;
    self.animationTimelineViewController.scrollView.scrollingDelegate = self;
    
}

/**
 * Inits the VSScrollView in the left part of the splitView and inits it's subviews
 */
-(void) initLeftScrollView{
    
    [self.leftScrollView setAutoresizesSubviews:YES];
    self.leftScrollView.scrollingDelegate = self;
    
    [self.leftScrollView setHorizontalRulerView:[[VSEmtpyRuler alloc] initWithScrollView:self.leftScrollView
                                                                             orientation:NSHorizontalRuler]];
    
    //adds an empty rulerview above the parameters that the are on the same height as the animation timline*/
    [self.leftScrollView.horizontalRulerView setRuleThickness:self.animationTimelineViewController.scrollView.horizontalRulerView.ruleThickness];
    
    [self.leftScrollView setHasHorizontalRuler:YES];
    [self.leftScrollView setRulersVisible:YES];
    
    
    [((NSView*)self.leftScrollView.documentView) setAutoresizingMask:NSViewWidthSizable];
    [self.leftScrollView.documentView setAutoresizesSubviews:YES];
    
    [self.leftScrollView.documentView setFrameSize:self.leftScrollView.visibleRect.size];
    
    [self initParameterView];
    [self initDevicesView];
}

/**
 * Instantiates a VSTimelineObjectParametersViewController, stores its view as subView of parametersHolder and sets the view's properties
 */
-(void) initParameterView{
    [self.leftScrollView.documentView addSubview:self.parametersDisclosureView];
    
    [self.parametersDisclosureView setAutoresizesSubviews:YES];
    [self.parametersDisclosureView setAutoresizingMask: NSViewWidthSizable];

    
    [self.parametersDisclosureView setFrameSize:NSMakeSize(self.leftScrollView.visibleRect.size.width, self.parametersDisclosureView.frame.size.height)];
    
    self.parametersViewController = [[VSTimelineObjectParametersViewController alloc] initWithDefaultNibAndParameterViewHeight:PARAMETER_VIEW_HEIGHT];
    
    //sets the zebra-colors
    self.parametersViewController.oddColor = [NSColor lightGrayColor];
    self.parametersViewController.evenColor = [NSColor darkGrayColor];
    
    [self.parametersViewController.view setAutoresizingMask:NSViewWidthSizable];
    [self.parametersViewController.view setAutoresizesSubviews:YES];
    
    [self.parametersViewController.view setFrameSize:NSMakeSize(100, self.parametersViewController.view.frame.size.height)];
    
    [self.parametersDisclosureView.contentView addSubview:self.parametersViewController.view];
}

/**
 * Allocs VSTimelineObjectDevicesViewController inits its view and sets it as subview of leftScrollView's documentView
 */
-(void) initDevicesView{
    [self.leftScrollView.documentView addSubview:self.deviceDisclosureView];
    
    NSRect deviceDisclosureViewFrame;
    deviceDisclosureViewFrame.origin = NSMakePoint(self.deviceDisclosureView.frame.origin.x,
                                                   NSMaxY(self.parametersDisclosureView.frame));
    
    deviceDisclosureViewFrame.size = NSMakeSize(self.leftScrollView.visibleRect.size.width,
                                                self.parametersDisclosureView.frame.size.height);

    
    [self.deviceDisclosureView setFrame:deviceDisclosureViewFrame];
    
    [self.deviceDisclosureView setAutoresizesSubviews:YES];
    [self.deviceDisclosureView setAutoresizingMask: NSViewWidthSizable];
    
    
    self.timelineObjectDevicesViewController = [[VSTimelineObjectDevicesViewController alloc] initWithDefaultNibAndDeviceViewHeight:DEVICE_VIEW_HEIGHT];
    
    [self.deviceDisclosureView.contentView addSubview:self.timelineObjectDevicesViewController.view];
    
    [self.timelineObjectDevicesViewController.view setFrameSize:NSMakeSize(self.deviceDisclosureView.frame.size.width,
                                                                self.parametersViewController.view.frame.size.height)];
    
    
    [self.timelineObjectDevicesViewController.view setAutoresizesSubviews:YES];
    [self.timelineObjectDevicesViewController.view setAutoresizingMask:NSViewWidthSizable];
    
}

#pragma mark -
#pragma mark Methods

-(void) willBeHidden{
    [self.animationTimelineViewController resetTimeline];
    [self.parametersViewController resetParameters];
    self.timelineObject = nil;
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
    return YES;
}

-(BOOL) wantToUnselectKeyFrame:(VSKeyFrame *)keyFrame ofParamater:(VSParameter *)parameter{
    
    [self.parametersViewController unselectKeyFrame:keyFrame ofParameter:parameter];
    
    return YES;
}

-(BOOL) keyFrame:(VSKeyFrame *)keyFrame ofParameter:(VSParameter *)parameter willBeMovedFromTimestamp:(double)fromTimestamp toTimestamp:(double *)toTimestamp andFromValue:(id)fromValue toValue:(__autoreleasing id *)toValue{
    
    [parameter changeKeyFrames:keyFrame timestamp:*toTimestamp];
    keyFrame.value = *toValue;
    
    [self updateCurrentValueOfParameter:parameter];
    
    return YES;
}

-(BOOL) selectedKeyFramesWantsBeDeleted{
    [self.parametersViewController unselectAllSelectedKeyFrames];
    
    return YES;
}

#pragma mark
#pragma mark - VSScrollViewScrollingDelegate Implementation

-(void) scrollView:(NSScrollView *)scrollView changedBoundsFrom:(NSRect)fromBounds to:(NSRect)toBounds{
    
    VSScrollView *scrollViewToScroll = nil;
    
    if([scrollView isEqual:self.animationTimelineViewController.scrollView]){
        scrollViewToScroll = self.leftScrollView;
    }
    else if([scrollView isEqual:self.leftScrollView]){
        scrollViewToScroll = self.animationTimelineViewController.scrollView;
    }
    
    if(scrollViewToScroll){
        NSPoint newBoundsOrigin = NSMakePoint(scrollViewToScroll.contentView.bounds.origin.x, toBounds.origin.y);
        
        [scrollViewToScroll setBoundsOriginWithouthNotifiying:newBoundsOrigin];
        
    }
    
    
}

#pragma mark - VSDisclosureViewDelegate

-(BOOL) willShowContentOfDisclosureView:(VSDisclosureView *)disclosureView{
    if([disclosureView isEqual:self.parametersDisclosureView]){
        NSSize newSize = [self.animationTimelineViewController.scrollView.documentView frame].size;
        newSize.height = self.animationTimelineViewController.scrollView.documentsContentHeight;
        [((NSView*) self.animationTimelineViewController.scrollView.documentView).animator setFrameSize:newSize];
    }
    
    return YES;
}

-(BOOL) willHideContentOfDisclosureView:(VSDisclosureView *)disclosureView{
    if([disclosureView isEqual:self.parametersDisclosureView]){
        NSSize newSize = [self.animationTimelineViewController.scrollView.documentView frame].size;
        newSize.height = 0;
        [((NSView*) self.animationTimelineViewController.scrollView.documentView).animator setFrameSize:newSize];
    }
    
    return YES;
}

-(void) didHideContentOfDisclosureView:(VSDisclosureView *)disclosureView{
    [self updateSubviewSizes];
}

-(void) didShowContentOfDisclosureView:(VSDisclosureView *)disclosureView{
    [self updateSubviewSizes];
}

-(void) contentSizeDidChangeOfDisclosureView:(VSDisclosureView *)disclosureView{
    if([disclosureView isEqual:self.parametersDisclosureView]){
        NSRect newRect = self.parametersDisclosureView.frame;
        newRect.size.height = self.parametersDisclosureView.intrinsicContentSize.height;
        [self.parametersDisclosureView setFrameSize:NSMakeSize([self.leftScrollView.documentView frame].size.width, self.parametersDisclosureView.intrinsicContentSize.height)];
        
        [self.deviceDisclosureView setFrameOrigin:NSMakePoint(self.deviceDisclosureView.frame.origin.x, NSMaxY(self.parametersDisclosureView.frame))];
    }
    else if([disclosureView isEqual:self.deviceDisclosureView]){
        [self.deviceDisclosureView setFrameSize:self.deviceDisclosureView.intrinsicContentSize];
        [self.deviceDisclosureView setFrameSize:NSMakeSize([self.leftScrollView.documentView frame].size.width, self.deviceDisclosureView.intrinsicContentSize.height)];
    }
    
    [self updateSubviewSizes];
}



#pragma mark - 
#pragma mark Private Methods

/**
 * Updates the currentValue of the parameter according of the currentTimePosition of the animationTimeline's playhead
 *
 * @param parameter VSParameter which currentValue is going to be update
 */
-(void) updateCurrentValueOfParameter:(VSParameter*) parameter{
    [parameter updateCurrentValueForTimestamp: [self.timelineObject localTimestampOfGlobalTimestamp:self.animationTimelineViewController.playhead.currentTimePosition]];
}

/**
 * Updates the currentValue of all parameters of the timelineobject according of the currentTimePosition of the animationTimeline's playhead
 */
-(void) updateCurrentValueOfAllParameters{
    for (VSParameter *parameter in self.timelineObject.visibleParameters){
        [self updateCurrentValueOfParameter:parameter];
    }
}

/**
 * Changes the paramters name
 * @param newName Name the the VSTimelineObject's name will be changed to
 */
-(void) setTimelineObjectName:(NSString*)newName{
    if(![self.timelineObject.name isEqualToString:newName]){
        [self.timelineObject changeName:newName andRegisterAt:self.view.undoManager];
    }
}


#pragma mark - Show Propertis

/**
 * Tells the parametersViewController to show the parameters of the timelineObject
 */
-(void) showParameters{
    
    [self.parametersViewController showParametersOfTimelineObject:self.timelineObject
                                            connectedWithDelegate:self];
    
}

/**
 * tells timelineObjectDevicesViewController to display all devices connected with the timelineObject
 */
-(void) showDevices{
    [self.timelineObjectDevicesViewController reset];
    
    [self.timelineObjectDevicesViewController showDevicesOfTimelineObject:self.timelineObject];
}


/**
 * Updates the heights of the documentViews of the scrollViews stored in the left and right splitview to make them the same height.
 */
-(void) updateSubviewSizes{
    
    float totalHeight = self.parametersDisclosureView.frame.size.height + self.deviceDisclosureView.intrinsicContentSize.height;
    
    NSRect newFrame = [self.parametersHolderSplitView frame];
    newFrame.size.height = totalHeight;
    
    NSSize leftScrollViewSize = [self.leftScrollView.documentView frame].size;
    NSSize animationScrollViewSize = [self.animationTimelineViewController.scrollView.documentView frame].size;

    leftScrollViewSize.height = newFrame.size.height;
    animationScrollViewSize.height  = newFrame.size.height;
    
    if([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy){
        leftScrollViewSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    }
    
    
    [self.leftScrollView.documentView setFrameSize:leftScrollViewSize];
    [self.animationTimelineViewController.scrollView.documentView setFrameSize:animationScrollViewSize];
    
}

/**
 * Tells the animationTimelineViewController to show the the animationTimeline of the timelineObject
 */
-(void) showAnimationTimeline{
    [self.animationTimelineViewController showTimelineForTimelineObject:self.timelineObject];
}


/**
 * Called when the style of the scroller ("hide automatically") has been changed in the systems preferences
 *
 * @param notification NSNotification of the Evenet
 */
-(void) scrollerStyleDidChange:(NSNotification*) notification{
    
    NSSize newSize = [self.leftScrollView.documentView frame].size;
    
    if([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy){
        newSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    }
    else{
        newSize.height -= self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    }
    
    [self.leftScrollView.documentView setFrameSize:newSize];
    
}




#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        
        if(_timelineObject){
        }
        
        _timelineObject = timelineObject;
        
        if(_timelineObject){
            
            [self showAnimationTimeline];
            [self showParameters];
            [self showDevices];
            
            [self updateSubviewSizes];
            
            [self.animationTimelineViewController.scrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
            [self.leftScrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
        }
        
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}

@end
