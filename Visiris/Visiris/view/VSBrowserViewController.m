//
//  VSBrowserViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSBrowserViewController.h"

// ContentViews
#import "VSProjectItemBrowserViewController.h"
#import "VSDeviceConfigurationViewController.h"


@interface VSBrowserViewController ()
/** Responsible for the ProjectItem browser View */
@property (strong) VSProjectItemBrowserViewController* projectItemBrowserViewController;

/** Responsible for the device configuration view */
@property (strong) VSDeviceConfigurationViewController* deviceConfigurationViewController;

/** List of all ViewControllers which views are displayed as subivews of the browserView */
@property (strong) NSMutableDictionary *subViewControllers;
@end

@implementation VSBrowserViewController
@synthesize contentView = _contentView;
@synthesize sgmCtrlSelectSubview = _sgmCtrlSelectSubview;
@synthesize subViewControllers = _subViewControllers;
@synthesize projectItemBrowserViewController = _projectItemBrowserViewController;
@synthesize deviceConfigurationViewController = _deviceConfigurationViewController;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSBrowserView";

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

-(void) awakeFromNib{
    [self.sgmCtrlSelectSubview setAutoresizingMask:NSViewWidthSizable];
    [self initSubViewControllers];
    [self.sgmCtrlSelectSubview setAutoresizingMask:NSViewWidthSizable];
    [self setSegmentControllsSegmentsNames];
    
    [self.sgmCtrlSelectSubview setSelectedSegment:0];
    [self showSubViewByIndex:0];
}

/**
 * Sets the names of the segments of the Segment control
 */
-(void) setSegmentControllsSegmentsNames{
    [self.sgmCtrlSelectSubview setLabel:NSLocalizedString(@"Project Items", @"Segment label for the Project-Items-Browser in the BrowserView") forSegment:0];
    
    [self.sgmCtrlSelectSubview setLabel:NSLocalizedString(@"Files", @"Segment label for the FileBrowser in the BrowserView") forSegment:1];
    
    [self.sgmCtrlSelectSubview setLabel:NSLocalizedString(@"Devices", @"Segment label for the Devices-Browser in the BrowserView") forSegment:2];
}


/**
 * Inits the controllers responsible for the view's subviews.
 *
 *The controllers are stored in the subViewControllers Dictionary where their keys are representing the conencted segment of sgmCtrlSelectSubview
 */
-(void) initSubViewControllers{
    self.subViewControllers = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    // project item browser
    self.projectItemBrowserViewController = [[VSProjectItemBrowserViewController alloc] initWithDefaultNib];
    [self.subViewControllers setObject:self.projectItemBrowserViewController forKey:[NSNumber numberWithInt:0]];
    
    // device configuration editor
    self.deviceConfigurationViewController = [[VSDeviceConfigurationViewController alloc] initWithDefaultNib];
    [self.subViewControllers setObject:self.deviceConfigurationViewController forKey:[NSNumber numberWithInt:2]];
    
    
}


#pragma mark -IBAction

- (IBAction)selectedSegmentHasBeenChanged:(NSSegmentedControl *)sender {
    [self showSubViewByIndex:[sender selectedSegment]];
}

#pragma mark - Private Methods

/**
 * Shows a subView according ot the given index.
 *
 *@param subViewID Key of the view to show in the subViewcontrollersDictionary
 */
-(void) showSubViewByIndex:(NSInteger) subViewID{
    //gets the view of the controller stored in the dictionary with subViewID as key 
    NSView* newView = [(NSViewController *)[self.subViewControllers objectForKey:[NSNumber numberWithInteger:subViewID]] view];
    
    if(newView){
        if([self.contentView.subviews count] > 0){
//            [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            [self.contentView addSubview:newView];
            [self.contentView replaceSubview:[self.contentView.subviews objectAtIndex:0] with:newView];
        }
        else {
            [self.contentView addSubview:newView];
        }
        
        [newView setFrame:NSIntegralRect([self.contentView bounds])];
        [newView setAutoresizesSubviews:YES];
        [newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
}

@end
