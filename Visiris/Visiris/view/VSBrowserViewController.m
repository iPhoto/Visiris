//
//  VSBrowserViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSBrowserViewController.h"

#import "VSProjectItemBrowserViewController.h"

@interface VSBrowserViewController ()
/** Responsible for the ProjectItem browser View */
@property (strong) VSProjectItemBrowserViewController* projectItemBrowserViewController;

/** List of all ViewControllers which views are displayed as subivews of the browserView */
@property (strong) NSMutableDictionary *subViewControllers;
@end

@implementation VSBrowserViewController
@synthesize contentView = _contentView;
@synthesize sgmCtrlSelectSubview = _sgmCtrlSelectSubview;
@synthesize subViewControllers = _subViewControllers;
@synthesize projectItemBrowserViewController = _projectItemBrowserViewController;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSBrowserView";

#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        [self initSubViewControllers];
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
    [self showSubViewByIndex:[self.sgmCtrlSelectSubview selectedSegment]];
}

- (IBAction)selectedSegmentHasBeenChanged:(NSSegmentedControl *)sender {
    [self showSubViewByIndex:[sender selectedSegment]];
}


/**
 * Inits the controllers responsible for the view's subviews.
 *
 *The controllers are stored in the subViewControllers Dictionary where their keys are representing the conencted segment of sgmCtrlSelectSubview
 */
-(void) initSubViewControllers{
    self.subViewControllers = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    self.projectItemBrowserViewController = [[VSProjectItemBrowserViewController alloc] initWithDefaultNib];
    
    [self.subViewControllers setObject:self.projectItemBrowserViewController.view forKey:[NSNumber numberWithInt:0]];
}

#pragma mark - Private Methods

/**
 * Shows a subView according ot the given index.
 *
 *@param subViewID Key of the view to show in the subViewcontrollersDictionary
 */
-(void) showSubViewByIndex:(NSInteger) subViewID{
    //gets the view of the controller stored in the dictionary with subViewID as key 
    NSView* newView = [self.subViewControllers objectForKey:[NSNumber numberWithInt:subViewID]];
    
    if(newView){
        if([self.contentView.subviews count] > 0){
            [self.contentView replaceSubview:[self.contentView.subviews objectAtIndex:0] with:newView];
        }
        else {
            [self.contentView addSubview:newView];
        }
        
        [newView setFrame:[self.contentView bounds]];
        [newView setAutoresizesSubviews:YES];
        [newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
}

@end
