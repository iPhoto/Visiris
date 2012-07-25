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

#import "VSCoreServices.h"

@interface VSTimelineObjectPropertiesViewController ()

@end

@implementation VSTimelineObjectPropertiesViewController

/** Height of the parameter views */
static int parameterViewHeight = 40;


@synthesize documentView = _documentView;
@synthesize scrollView = _scrollView;
@synthesize timelineObject = _timelineObject;
@synthesize parameterViewControllers = _parameterViewControllers;
@synthesize parametersHolder = _parametersHolder;
@synthesize nameLabel = _nameLabel;
@synthesize nameTextField = _nameTextField;

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

#pragma mark - VSViewController

- (void) awakeFromNib{
    self.parameterViewControllers = [[NSMutableArray alloc] init];
    [self initScrollView];
    
    [self.nameLabel setStringValue:NSLocalizedString(@"Name", @"Label for the name of a VSTimelineObject in its properties view")];
}

/**
 * Inits the scrollView and its documentView
 */
-(void) initScrollView{
    [self.documentView setAutoresizingMask:NSViewWidthSizable];
    [self.scrollView setDocumentView:self.documentView];
    [self.documentView setAutoresizesSubviews:YES];
    [self.parametersHolder setAutoresizingMask:NSViewWidthSizable];
    [self.documentView setFrameSize: [self.scrollView contentSize]];
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
    for(VSParameter *parameter in [self.timelineObject visibleParameters]){
        
        NSRect viewFrame = NSMakeRect(0, self.parameterViewControllers.count * parameterViewHeight, self.documentView.frame.size.width, parameterViewHeight);
        
        
        VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNib];
        [parameteViewController.view setFrame:NSIntegralRect(viewFrame)];
        
        parameteViewController.parameter = parameter;
        
        [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
        [parameteViewController.view setAutoresizesSubviews:YES];
        
        [self.parametersHolder addSubview:parameteViewController.view];
        
        
        if(self.parameterViewControllers.count > 0){
            [[[self.parameterViewControllers lastObject] view] setNextKeyView:parameteViewController.view];        
            
        }
        
        [self.parameterViewControllers addObject:parameteViewController];
    }
    
    
    
    [self.documentView setFrameSize: NSMakeSize(self.documentView.frame.size.width, ([self.parameterViewControllers count] + 1) * parameterViewHeight)];
    
    [self.parametersHolder setFrameSize:NSMakeSize(self.documentView.frame.size.width, ([self.parameterViewControllers count] + 1) * parameterViewHeight)];
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
