//
//  VSTimelineObjectPropertiesControllerViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectPropertiesViewController.h"

#import "VSTimelineObject.h"
#import "VSParameterViewController.h"
#import "VSParameterView.h"
#import "VSTimelineObjectSource.h"
#import "VSParameter.h"
#import "VSTestView.h"
#import "VSTimelineObjectPropertiesView.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

@end

@implementation VSTimelineObjectPropertiesViewController

/** Height of the parameter views */
#define PARAMETER_VIEW_HEIGHT 50
#define PARAMETER_VIEW_MINIMUM_WIDTH 150
#define PARAMETER_VIEW_MAXIMUM_WIDTH 200

@synthesize splitView                   = _splitView;
@synthesize parametersHolder            = _parametersHolder;
@synthesize animationTimelineHolder     = _animationTimelineHolder;
@synthesize scrollView                  = _scrollView;
@synthesize timelineObject              = _timelineObject;
@synthesize parameterViewControllers    = _parameterViewControllers;
@synthesize nameLabel                   = _nameLabel;
@synthesize nameTextField               = _nameTextField;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectPropertiesView";


#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.parameterViewControllers = [[NSMutableArray alloc] init];
        [self initScrollView];
        //
        [self.view setAutoresizesSubviews:NO];
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

#pragma mark - VSViewController

- (void) awakeFromNib{
    [self initScrollView];
    if([self.view isKindOfClass:[VSTimelineObjectPropertiesView class] ]){
        ((VSTimelineObjectPropertiesView*) self.view).resizingDelegate = self;
    }
    
    [self.splitView setPosition:PARAMETER_VIEW_MINIMUM_WIDTH ofDividerAtIndex:0];
}

/**
 * Inits the scrollView and its documentView
 */
-(void) initScrollView{
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.view setAutoresizesSubviews:YES];
    
    [self.documentView removeConstraints:self.view.constraints];
    
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.scrollView setAutoresizesSubviews:YES];
    
    self.documentView = (NSView*) self.scrollView.documentView;
    [self.documentView setAutoresizingMask:NSViewWidthSizable];
    [self.documentView setAutoresizesSubviews:YES];
    
    [self.splitView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.splitView setAutoresizesSubviews:YES];
    [self.splitView setAutoresizingMask:NSViewWidthSizable];
    [self.splitView setPosition:PARAMETER_VIEW_MINIMUM_WIDTH ofDividerAtIndex:0];
    
    [self.animationTimelineHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    [self.parametersHolder setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask: NSViewWidthSizable];
    
    [self.parametersHolder setTranslatesAutoresizingMaskIntoConstraints:YES];
}


#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"name"]) {
        [self.nameTextField setStringValue:[object valueForKey:keyPath]];
    }
}

#pragma mark - NSSplitViewDelegate Implementation

-(CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    NSView* subView = [splitView.subviews objectAtIndex:0];
    return  subView.frame.origin.x + PARAMETER_VIEW_MINIMUM_WIDTH;
}

-(CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    return PARAMETER_VIEW_MAXIMUM_WIDTH;
}

-(void) splitViewDidResizeSubviews:(NSNotification *)notification{
    BOOL sizeDoesFit = YES;
    float deltaWidth;
    
    if(self.parametersHolder.frame.size.width < PARAMETER_VIEW_MINIMUM_WIDTH){
        
        deltaWidth = self.parametersHolder.frame.size.width - PARAMETER_VIEW_MINIMUM_WIDTH;
        
        [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MINIMUM_WIDTH, self.parametersHolder.frame.size.height)];
        
        sizeDoesFit = NO;
        
    }
    else if(self.parametersHolder.frame.size.width > PARAMETER_VIEW_MAXIMUM_WIDTH){
        
        deltaWidth = self.parametersHolder.frame.size.width - PARAMETER_VIEW_MAXIMUM_WIDTH;
        
        [self.parametersHolder setFrameSize:NSMakeSize(PARAMETER_VIEW_MAXIMUM_WIDTH, self.parametersHolder.frame.size.height)];
        
        sizeDoesFit = NO;
    }
    
    if(!sizeDoesFit){
        NSView *secondView = [self.splitView.subviews objectAtIndex:1];
        
        NSRect resizedRect = secondView.frame;
        
        resizedRect.size.width +=deltaWidth;
        resizedRect.origin.x += deltaWidth;
        
        [secondView setFrame:resizedRect];
    }
}

#pragma mark IBAction
- (IBAction)nameTextFieldHasChanged:(NSTextField *)sender {
    [self setTimelineObjectName:[sender stringValue]];
}

#pragma mark - VSFrameResizingDelegate Implementation

-(void) frameOfView:(NSView *)view wasSetTo:(NSRect)newRect{
    if(self.scrollView.contentView.frame.size.height > ([self.parameterViewControllers count] * PARAMETER_VIEW_HEIGHT)){
        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, self.scrollView.contentView.frame.size.height)];
    }
    else{
        [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, [self.parameterViewControllers count] * PARAMETER_VIEW_HEIGHT)];
    }
    
    
}

#pragma mark - Private Methods

/**
 * Removes all Parameter views
 */
-(void) resetParameters{
    for(VSParameterViewController *ctrl in self.parameterViewControllers){
        [ctrl saveParameterAndRemoveObserver];
        [ctrl.view removeFromSuperview];
    }
    
    [self.parameterViewControllers removeAllObjects];
}

/**
 * Resets the position of scrollView's scrollBars
 */
-(void) resetScrollingPosition{
    
    NSPoint newScrollOrigin=NSMakePoint(0.0,0.0);
    [[self.scrollView documentView] scrollPoint:newScrollOrigin];
}

/**
 * Inits and displays a ParameterView for every parameter stored in the timelineObject property
 */
-(void) showParameters{
    
    for(VSParameter *parameter in [self.timelineObject visibleParameters]){
        
        NSRect viewFrame = NSMakeRect(0, self.parameterViewControllers.count * PARAMETER_VIEW_HEIGHT, self.parametersHolder.frame.size.width, PARAMETER_VIEW_HEIGHT);
        
        VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNib];
        if(self.parameterViewControllers.count){
            VSParameterViewController *lastParameterController = [self.parameterViewControllers lastObject];
            
            [lastParameterController.view setNextKeyView:parameteViewController.view];
        }
        else{
            [self.view.window makeFirstResponder:parameteViewController.view];
        }
        
        
        [self.parametersHolder addSubview:parameteViewController.view];
        [parameteViewController showParameter:parameter inFrame:viewFrame];
        [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
        [parameteViewController.view setAutoresizesSubviews:YES];
        
       
        
        [self.parameterViewControllers addObject:parameteViewController];
    }
    

    [self.splitView setPosition:self.parametersHolder.frame.size.width ofDividerAtIndex:0];
    [self.documentView setFrameSize:NSMakeSize(self.documentView.frame.size.width, ([self.parameterViewControllers count]) * PARAMETER_VIEW_HEIGHT)];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for(VSParameterViewController *ctrl in self.parameterViewControllers){
        //    [constraints addObjectsFromArray:ctrl.view.constraints];
        [constraints addObjectsFromArray:ctrl.parameterHolder.constraints];
    }
    [self.view.window recalculateKeyViewLoop];
    // [self.view.window visualizeConstraints:constraints];
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

#pragma mark - Properties

-(void) setTimelineObject:(VSTimelineObject *)timelineObject{
    if(_timelineObject != timelineObject){
        if(_timelineObject){
            [self.timelineObject removeObserver:self forKeyPath:@"name"];
            [self setTimelineObjectName:[self.nameTextField stringValue]];
            [self resetParameters];
        }
        
        _timelineObject = timelineObject;
        
        [self.timelineObject addObserver:self forKeyPath:@"name" options:0 context:nil];
        
        //  [self.nameTextField setStringValue:self.timelineObject.name];
        [self showParameters];
        [self resetScrollingPosition];
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}


@end
