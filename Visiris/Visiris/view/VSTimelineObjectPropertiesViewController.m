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

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

@property (strong) VSAnimationTimelineViewController *animationTimelineViewController;

@property (strong) VSTimelineObjectParametersViewController *parametersViewController;

@property int numberOfParameters;

@end

@implementation VSTimelineObjectPropertiesViewController

@synthesize timelineObject = _timelineObject;

/** Height of the parameter views */
#define PARAMETER_VIEW_HEIGHT 70
#define PARAMETER_VIEW_MINIMUM_WIDTH 150
#define PARAMETER_VIEW_MAXIMUM_WIDTH 200


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
    
    
    
    [self.leftSplittedView setAutoresizesSubviews:YES];
    [self.leftSplittedView setAutoresizingMask:NSViewWidthSizable];
    [self.leftSplittedView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftSplittedView setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.leftSplittedView.frame.size.height)];
    
    [self initAnimationTimeline];
    
    [self initParameterView];
    
    [self animationTimelineHolder];
    
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
    
    float width = self.view.frame.size.width - PARAMETER_VIEW_MINIMUM_WIDTH - self.parametersHolderSplitView.dividerThickness;
    
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
    
    [self.parametersDisclosureView setAutoresizesSubviews:YES];
    [self.parametersDisclosureView setAutoresizingMask: NSViewWidthSizable];
    
    
    [self.parametersDisclosureView.contentView setAutoresizesSubviews:YES];
    [self.parametersDisclosureView.contentView setAutoresizingMask: NSViewWidthSizable];
    
    
    
    [self.parametersDisclosureView setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersDisclosureView.frame.size.height)];
    [self.parametersDisclosureView.contentView setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersDisclosureView.contentView.frame.size.height)];
    
    self.parametersViewController = [[VSTimelineObjectParametersViewController alloc] initWithDefaultNibAndParameterViewHeight:PARAMETER_VIEW_HEIGHT];
    
    self.parametersViewController.oddColor = [NSColor lightGrayColor];
    self.parametersViewController.evenColor = [NSColor darkGrayColor];
    
    [self.parametersDisclosureView.contentView addSubview:self.parametersViewController.view];
    
    [self.parametersViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.parametersViewController.view setAutoresizesSubviews:YES];
    
    [self.parametersViewController.view setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersViewController.view.frame.size.height)];

    float yOffset =self.animationTimelineViewController.scrollView.horizontalRulerView.frame.size.height;
    [self.parametersDisclosureWrapperViewVerticalTopConstraint setConstant:yOffset];
//
//    NSRect parametersViewFrame = self.parametersDisclosureWrapperView.frame;
////    parametersViewFrame.size.height -= yOffset;
//    parametersViewFrame.size.width = PARAMETER_VIEW_MINIMUM_WIDTH;
//    parametersViewFrame.origin.x = 0;
//    parametersViewFrame.origin.y = yOffset;
//    
//    [self.parametersDisclosureWrapperView setFrame:parametersViewFrame];
//    
//    
//    NSString *constraintString = [NSString stringWithFormat:@"V:|-%f-[parametersDisclosureWrapperView]|", yOffset];
//
////    [self.leftSplittedView removeConstraints:self.leftSplittedView.constraints];
//
//    [self.leftSplittedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
//                                                                                  options:0
//                                                                                  metrics:nil
//                                                                                    views:[NSDictionary dictionaryWithObject:self.parametersDisclosureWrapperView forKey:@"parametersDisclosureWrapperView"]]];
    
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
    else if([keyPath isEqualToString:@"startTime"]){
        [self.animationTimelineViewController updatePlayheadPosition];
        [self updateCurrentValueOfAllParameters];
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

//#pragma mark -
//#pragma mark IBAction
//
//- (IBAction)disclosureButtonStateDidChange:(NSButton*)sender {
//    if([sender isEqual:self.devicesDisclosureButton]){
//        NSView *viewToHide = [self.devicesDisclosureWrapperView.subviews objectAtIndex:0];
//        if(!sender.state){
//            [viewToHide setHidden:YES];
//            NSPoint newOrigin = self.parametersDisclosureWrapperView.frame.origin;
//            newOrigin.y += viewToHide.frame.size.height;
//            [self.parametersDisclosureWrapperView setFrameOrigin:newOrigin];
//        }
//        else{
//            [viewToHide setHidden:NO];
//            NSPoint newOrigin = self.parametersDisclosureWrapperView.frame.origin;
//            newOrigin.y -= viewToHide.frame.size.height;
//            [self.parametersDisclosureWrapperView setFrameOrigin:newOrigin];
//        }
//    }
//    else if([sender isEqual:self.parametersDisclosureButton]){
//        NSView *viewToHide = [self.parametersDisclosureWrapperView.subviews objectAtIndex:0];
//        if(!sender.state){
//            [viewToHide setHidden:YES];
//        }
//        else{
//            [viewToHide setHidden:NO];
//        }
//    }
//}


#pragma mark - Private Methods

-(void) updateCurrentValueOfParameter:(VSParameter*) parameter{
    [parameter updateCurrentValueForTimestamp: [self.timelineObject localTimestampOfGlobalTimestamp:self.animationTimelineViewController.playhead.currentTimePosition]];
}

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

/**
 * Tells the parametersViewController to show the parameters of the timelineObject
 */
-(void) showParameters{
    [self.parametersViewController showParametersOfTimelineObject:self.timelineObject connectedWithDelegate:self];
    
    if([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy){
        NSSize newSize = [self.parametersViewController.scrollView.documentView frame].size;
        
        newSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
        
        [self.parametersViewController.scrollView.documentView setFrameSize:newSize];
    }
}

/**
 * Tells the animationTimelineViewController to show the the animationTimeline of the timelineObject
 */
-(void) showAnimationTimeline{
    [self.animationTimelineViewController showTimelineForTimelineObject:self.timelineObject];
}

-(void) scrollerStyleDidChange:(NSNotification*) notification{
    
    NSSize newSize = [self.parametersViewController.scrollView.documentView frame].size;
    
    if([NSScroller preferredScrollerStyle] == NSScrollerStyleLegacy){
        newSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    }
    else{
        newSize.height -= self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    }
    
    [self.parametersViewController.scrollView.documentView setFrameSize:newSize];
    
}


#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        
        
        if(_timelineObject){
            [self.timelineObject removeObserver:self
                                     forKeyPath:@"startTime"];
            [self setTimelineObjectName:[self.nameTextField stringValue]];
            [self.parametersViewController resetParameters];
            
        }
        
        _timelineObject = timelineObject;
        
        [self.timelineObject addObserver:self
                              forKeyPath:@"startTime"
                                 options:0
                                 context:nil];
        
        self.numberOfParameters = [timelineObject visibleParameters].count;
        
        [self showAnimationTimeline];
        [self showParameters];
        
        [self.animationTimelineViewController.scrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
        [self.parametersViewController.scrollView setBoundsOriginWithouthNotifiying:NSZeroPoint];
        
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}

@end
