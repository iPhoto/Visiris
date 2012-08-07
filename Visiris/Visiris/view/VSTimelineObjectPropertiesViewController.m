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

#import "VSCoreServices.h"

@interface VSTimelineObjectPropertiesViewController ()

@property NSView *documentView;

@end

@implementation VSTimelineObjectPropertiesViewController

/** Height of the parameter views */
@synthesize splitView = _splitView;
@synthesize parametersHolder = _parametersHolder;
static int parameterViewHeight = 40;
@synthesize scrollView = _scrollView;
@synthesize timelineObject = _timelineObject;
@synthesize parameterViewControllers = _parameterViewControllers;
@synthesize nameLabel = _nameLabel;
@synthesize nameTextField = _nameTextField;

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
}

/**
 * Inits the scrollView and its documentView
 */
-(void) initScrollView{
    self.documentView = (NSView*) self.scrollView.documentView;
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.view setAutoresizesSubviews:YES];
    
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    [self.scrollView setAutoresizesSubviews:YES];
    
    [self.splitView setAutoresizesSubviews:YES];
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.documentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.documentView setAutoresizesSubviews:YES];
    
    [self.parametersHolder setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask:NSViewWidthSizable];
    [self.parametersHolder setFrameSize:NSMakeSize(500, 0)];
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
    
    self.parameterViewControllers = [[NSMutableArray alloc]init];
    
    for(VSParameter *parameter in [self.timelineObject visibleParameters]){
        
        NSRect viewFrame = NSMakeRect(0, self.parameterViewControllers.count * parameterViewHeight, self.parametersHolder.frame.size.width, parameterViewHeight);
        
        
        VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNib];
        [parameteViewController.view setFrame:viewFrame];
        
        parameteViewController.parameter = parameter;
        
        [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
        [parameteViewController.view setAutoresizesSubviews:YES];
        
        
        
        [self.parametersHolder addSubview:parameteViewController.view];
        
        
        if(self.parameterViewControllers.count > 0){
            [[[self.parameterViewControllers lastObject] view] setNextKeyView:parameteViewController.view];        
            
        }
        
        [self.parameterViewControllers addObject:parameteViewController];
        
    }
    [self.splitView setFrameSize:NSMakeSize(self.parametersHolder.frame.size.width, ([self.parameterViewControllers count]) * parameterViewHeight)];
    [self.documentView setFrameSize:self.splitView.frame.size];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for(VSParameterViewController *ctrl in self.parameterViewControllers){
        [constraints addObjectsFromArray:ctrl.view.constraints];
    }
    
    [self.view.window visualizeConstraints:constraints];

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
        
        [self.nameTextField setStringValue:self.timelineObject.name];
        [self showParameters];
        [self resetScrollingPosition];
    }
}

-(VSTimelineObject*) timelineObject{
    return _timelineObject;
}


@end
