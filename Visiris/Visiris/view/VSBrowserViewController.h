//
//  VSBrowserViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Controls the browserView and all its subViews e.g.: ProjectItem-Browser, Files-Browser, Element-Browser 
 */
@interface VSBrowserViewController : NSViewController

/** Holds the differnte Browser-Subviews e.g.: ProjectItem-Browser, Files-Browser, Element-Browser */
@property (weak) IBOutlet NSView *contentView;

/** Control to select the different browser types e.g.: ProjectItem-Browser, Files-Browser, Element-Browser */
@property (weak) IBOutlet NSSegmentedControl *sgmCtrlSelectSubview;



/** 
 * Called when a different Segment got selected in sgmCtrlSelectSubview
 * @param sender the NSSegmentedControl
 * @return IBAction
 */
- (IBAction)selectedSegmentHasBeenChanged:(NSSegmentedControl *)sender;



/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

@end
