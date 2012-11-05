//
//  VSTimelineObjectPropertiesControllerViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineObjectPropertiesView.h"
#import "VSScrollView.h"
#import "VSParameterViewController.h"
#import "VSAnimationTimelineViewController.h"

@class VSTimelineObject;
@class VSTestView;

/**
 * Subclass of NSViewController displaying the properties of a VSTimelineObject
 *
 * Creates a VSParameterViewController for everey parameter of its VSTimelineObject
 */
@interface VSTimelineObjectPropertiesViewController : NSViewController<NSSplitViewDelegate, VSViewResizingDelegate, VSScrollViewScrollingDelegate, VSParameterViewKeyFrameDelegate, VSKeyFrameEditingDelegate>

/** VSTimelineObject which properties VSTimelineObjectPropertiesViewController is representing */
@property (strong) VSTimelineObject*timelineObject;

#pragma mark - Init

@property (weak) IBOutlet NSView *devicesDisclosureWrapperView;
@property (weak) IBOutlet NSView *parametersDisclosureWrapperView;

@property (weak) IBOutlet NSButton *parametersDisclosureButton;
@property (weak) IBOutlet NSButton *devicesDisclosureButton;

/** ScrollView's documentView */
@property (weak) IBOutlet NSSplitView *parametersHolderSplitView;

/** Wrapper for the VSParameterViews*/
@property (weak) IBOutlet NSView *parametersHolder;

/** Wrapper for the view of the VSAnimationTimelineViewController */
@property (weak) IBOutlet NSView *animationTimelineHolder;

- (IBAction)disclosureButtonStateDidChange:(NSButton*)sender;

@property (weak) IBOutlet NSView *deviceHolderView;

/** label for the name of VSTimelineObject */
@property (strong) NSTextField *nameLabel;

/** Textfield for the name of VSTimelineObject */
@property (strong) NSTextField *nameTextField;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;


/**
 * Called before the VSTimelineObjectPropertiesViewController is removed from superview. Tells its subviews to reset.
 */
-(void) willBeHidden;

@end
