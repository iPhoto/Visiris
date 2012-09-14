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

@property (strong) VSAnimationTimelineViewController *animationTimelineViewController;

@property (strong) VSTimelineObjectParametersViewController *timelineObjectsParameterViewController;

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


-(void) initAnimationTimeline{
    [self.animationTimelineHolder setAutoresizesSubviews:YES];
    [self.animationTimelineHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    float width = self.view.frame.size.width - PARAMETER_VIEW_MINIMUM_WIDTH - self.splitView.dividerThickness;
    
    [self.animationTimelineHolder setFrameSize:NSMakeSize(width, self.view.frame.size.height)];
    
    self.animationTimelineViewController = [[VSAnimationTimelineViewController alloc]initWithDefaultNibAndTrackHeight:PARAMETER_VIEW_HEIGHT];
    
    [self.animationTimelineHolder addSubview:self.animationTimelineViewController.view];
    
    
    self.animationTimelineViewController.scrollView.scrollingDelegate = self;
    
    [self.animationTimelineViewController.view setFrameSize:self.animationTimelineHolder.frame.size];
    
    [self.animationTimelineViewController.view setAutoresizesSubviews:YES];
    [self.animationTimelineViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.animationTimelineViewController.oddTrackColor = [NSColor lightGrayColor];
    self.animationTimelineViewController.evenTrackColor = [NSColor darkGrayColor];
    
}

-(void) initParameterView{
    [self.parametersHolder setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask: NSViewWidthSizable];
    [self.parametersHolder setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersHolder.frame.size.height)];
    
    self.timelineObjectsParameterViewController = [[VSTimelineObjectParametersViewController alloc] initWithDefaultNibAndParameterViewHeight:PARAMETER_VIEW_HEIGHT];
    
    self.timelineObjectsParameterViewController.oddColor = [NSColor lightGrayColor];
    self.timelineObjectsParameterViewController.evenColor = [NSColor darkGrayColor];
    
    [self.parametersHolder addSubview:self.timelineObjectsParameterViewController.view];
    
    [self.timelineObjectsParameterViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.timelineObjectsParameterViewController.view setAutoresizesSubviews:YES];
    
    float yOffset =self.animationTimelineViewController.scrollView.horizontalRulerView.frame.size.height;
    NSRect parametersViewFrame = self.parametersHolder.frame;
    
    parametersViewFrame.size.height -= yOffset;
    parametersViewFrame.origin.x = 0;
    parametersViewFrame.origin.y = yOffset;
    
    [self.timelineObjectsParameterViewController.view setFrame:parametersViewFrame];
    
    
    
    NSString *constraintString = [NSString stringWithFormat:@"V:|-%f-[parameterView]|", yOffset];
    
    //  [self.parametersHolder removeConstraints:self.parametersHolder.constraints];
    
    [self.parametersHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:[NSDictionary dictionaryWithObject:self.timelineObjectsParameterViewController.view forKey:@"parameterView"]]];
    
    [self.parametersHolder addConstraint:[NSLayoutConstraint constraintWithItem:self.timelineObjectsParameterViewController.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.parametersHolder
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0 constant:yOffset*(-1)]];
    
    
    self.timelineObjectsParameterViewController.scrollView.scrollingDelegate = self;
    
}


#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"name"]) {
        [self.nameTextField setStringValue:[object valueForKey:keyPath]];
    }
}

#pragma mark IBAction
- (IBAction)nameTextFieldHasChanged:(NSTextField *)sender {
    [self setTimelineObjectName:[sender stringValue]];
}

#pragma mark - VSFrameResizingDelegate Implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    //    if(self.timelineObjectsParameterViewController. > (self.numberOfParameters * PARAMETER_VIEW_HEIGHT)){
    //        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, self.scrollView.contentView.frame.size.height)];
    //    }
    //    else{
    //        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, [self parameterViewHeight])];
    //    }
}

#pragma mark - VSFrameResizingDelegate

-(void) scrollView:(NSScrollView *)scrollView changedBoundsFrom:(NSRect)fromBounds to:(NSRect)toBounds{
    VSScrollView *scrollViewToScroll = nil;
    
    if([scrollView isEqual:self.animationTimelineViewController.scrollView]){
        scrollViewToScroll = self.timelineObjectsParameterViewController.scrollView;
    }
    else if([scrollView isEqual:self.timelineObjectsParameterViewController.scrollView]){
        scrollViewToScroll = self.animationTimelineViewController.scrollView;
    }
    
    if(scrollViewToScroll){
        float deltaY = fromBounds.origin.y - toBounds.origin.y;
        
        NSPoint newBoundsOrigin = NSMakePoint(scrollViewToScroll.contentView.bounds.origin.x, scrollViewToScroll.contentView.bounds.origin.y - deltaY);
        
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

-(void) showParameters{
    [self.timelineObjectsParameterViewController showParametersOfTimelineObject:self.timelineObject];
    NSSize newSize = [self.timelineObjectsParameterViewController.scrollView.documentView frame].size;
    
    newSize.height += self.animationTimelineViewController.scrollView.horizontalScroller.frame.size.height;
    
    [self.timelineObjectsParameterViewController.scrollView.documentView setFrameSize:newSize];
}

-(void) showAnimationTimeline{
    [self.animationTimelineViewController showTimelineForTimelineObject:self.timelineObject];
}

#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        
        
        if(_timelineObject){
            //[self.timelineObject removeObserver:self forKeyPath:@"name"];
            [self setTimelineObjectName:[self.nameTextField stringValue]];
            [self.timelineObjectsParameterViewController resetParameters];
            
        }
        
        _timelineObject = timelineObject;
        
        self.numberOfParameters = [timelineObject visibleParameters].count;
        
        float width = self.view.frame.size.width - [[self.splitView.subviews objectAtIndex:0] frame].size.width - self.splitView.dividerThickness;

//        [self.timelineObject addObserver:self forKeyPath:@"name" options:0 context:nil];
        
        [self showParameters];
        
        [self showAnimationTimeline];
        
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}


@end
