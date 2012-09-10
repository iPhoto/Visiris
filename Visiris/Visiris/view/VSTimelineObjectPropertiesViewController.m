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
#import "VSAnimationTimelineContentView.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

@property VSAnimationTimelineViewController *animationTimelineViewController;

@property VSTimelineObjectParametersViewController *timelineObjectsParameterViewController;

@property int numberOfParameters;

@end

@implementation VSTimelineObjectPropertiesViewController

/** Height of the parameter views */
#define PARAMETER_VIEW_HEIGHT 80
#define PARAMETER_VIEW_MINIMUM_WIDTH 150
#define PARAMETER_VIEW_MAXIMUM_WIDTH 200

@synthesize splitView                   = _splitView;
@synthesize parametersHolder            = _parametersHolder;
@synthesize animationTimelineHolder     = _animationTimelineHolder;
@synthesize scrollView                  = _scrollView;
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
    if([self.view isKindOfClass:[VSTimelineObjectPropertiesView class] ]){
        ((VSTimelineObjectPropertiesView*) self.view).resizingDelegate = self;
    }
    
    [self initScrollView];
    
    [self initAnimationTimeline];
    
    [self initParameterView];
    
    [self animationTimelineHolder];
    
   // [self.splitView setPosition:PARAMETER_VIEW_MINIMUM_WIDTH ofDividerAtIndex:0];
}

/**
 * Inits the scrollView and its documentView
 */
-(void) initScrollView{
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.view setAutoresizesSubviews:YES];

    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.scrollView setAutoresizesSubviews:YES];

    [self.splitView setAutoresizesSubviews:YES];
    [self.splitView setAutoresizingMask:NSViewWidthSizable];
    
    self.documentView = (NSView*) self.scrollView.documentView;
    [self.documentView setAutoresizingMask:NSViewWidthSizable];
    [self.documentView setAutoresizesSubviews:YES];
}

-(void) initAnimationTimeline{
    [self.animationTimelineHolder setAutoresizesSubviews:YES];
    [self.animationTimelineHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    [self.animationTimelineViewController.view setAutoresizesSubviews:YES];
    [self.animationTimelineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.animationTimelineViewController = [[VSAnimationTimelineViewController alloc]initWithDefaultNibAndTrackHeight:PARAMETER_VIEW_HEIGHT];
    [self.animationTimelineHolder addSubview:self.animationTimelineViewController.view];
}

-(void) initParameterView{
    [self.parametersHolder setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask: NSViewWidthSizable];
    [self.parametersHolder setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.timelineObjectsParameterViewController = [[VSTimelineObjectParametersViewController alloc] initWithDefaultNibAndParameterViewHeight:PARAMETER_VIEW_HEIGHT];
    
    [self.parametersHolder addSubview:self.timelineObjectsParameterViewController.view];
    
    [self.timelineObjectsParameterViewController.view setFrameOrigin:NSMakePoint(0, self.animationTimelineViewController.scrollView.timelecodeRulerThickness)];

    [self.timelineObjectsParameterViewController.view setFrameSize:self.parametersHolder.frame.size];
    
    [self.timelineObjectsParameterViewController.view setAutoresizingMask:NSViewWidthSizable];
    [self.timelineObjectsParameterViewController.view setAutoresizesSubviews:YES];
    [self.timelineObjectsParameterViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    [self.view setNeedsLayout:YES];
    [self.view setNeedsUpdateConstraints:YES];
}


#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"name"]) {
        [self.nameTextField setStringValue:[object valueForKey:keyPath]];
    }
}

#pragma mark - NSSplitViewDelegate Implementation

//-(CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    NSView* subView = [splitView.subviews objectAtIndex:0];
//    return  subView.frame.origin.x + PARAMETER_VIEW_MINIMUM_WIDTH;
//}
//
//-(CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    return PARAMETER_VIEW_MAXIMUM_WIDTH;
//}
//
//-(void) splitViewDidResizeSubviews:(NSNotification *)notification{
//    BOOL sizeDoesFit = YES;
//    float deltaWidth;
//    
//    if(self.parametersHolder.frame.size.width < PARAMETER_VIEW_MINIMUM_WIDTH){
//        
//        deltaWidth = self.parametersHolder.frame.size.width - PARAMETER_VIEW_MINIMUM_WIDTH;
//        
//        [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersHolder.frame.size.height)];
//        
//        sizeDoesFit = NO;
//        
//    }
//    else if(self.parametersHolder.frame.size.width > PARAMETER_VIEW_MAXIMUM_WIDTH){
//        
//        deltaWidth = self.parametersHolder.frame.size.width - PARAMETER_VIEW_MAXIMUM_WIDTH;
//        
//        [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MAXIMUM_WIDTH, self.parametersHolder.frame.size.height)];
//        
//        sizeDoesFit = NO;
//    }
//    
//    if(!sizeDoesFit){
//        NSView *secondView = [self.splitView.subviews objectAtIndex:1];
//        
//        NSRect resizedRect = secondView.frame;
//        
//        resizedRect.size.width +=deltaWidth;
//        resizedRect.origin.x += deltaWidth;
//        
//        [secondView setFrame:resizedRect];
//    }
//}

#pragma mark IBAction
- (IBAction)nameTextFieldHasChanged:(NSTextField *)sender {
    [self setTimelineObjectName:[sender stringValue]];
}

#pragma mark - VSFrameResizingDelegate Implementation

-(void) frameOfView:(NSView *)view wasSetTo:(NSRect)newRect{
    if(self.scrollView.contentView.frame.size.height > (self.numberOfParameters * PARAMETER_VIEW_HEIGHT)){
        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, self.scrollView.contentView.frame.size.height)];
    }
    else{
        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, self.numberOfParameters * PARAMETER_VIEW_HEIGHT)];
    }
}

#pragma mark - Private Methods

/**
 * Resets the position of scrollView's scrollBars
 */
-(void) resetScrollingPosition{
    
    NSPoint newScrollOrigin=NSMakePoint(0.0,0.0);
    [[self.scrollView documentView] scrollPoint:newScrollOrigin];
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

-(void) showParameters{
    [self.timelineObjectsParameterViewController showParameters:[self.timelineObject visibleParameters]];
}

-(void) showAnimationTimeline{
    [self.animationTimelineViewController showTimelineForTimelineObject:self.timelineObject];
}

#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        if(_timelineObject){
            [self.timelineObject removeObserver:self forKeyPath:@"name"];
            [self setTimelineObjectName:[self.nameTextField stringValue]];
            [self.timelineObjectsParameterViewController resetParameters];
        }
        
        _timelineObject = timelineObject;
        
        self.numberOfParameters = [timelineObject visibleParameters].count;
        
        [self.timelineObject addObserver:self forKeyPath:@"name" options:0 context:nil];
        
        [self showAnimationTimeline];
        
        [self showParameters];
        
        [self resetScrollingPosition];
        
        [self.view setNeedsDisplay:YES];
        
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}


@end
