//
//  VSTimelineObjectPropertiesControllerViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimelineObject;

@interface VSTimelineObjectPropertiesViewController : NSViewController

@property VSTimelineObject *timelineObject;

#pragma mark - Init
/** ScrollView's documentView */
@property (weak) IBOutlet NSView *documentView;

/** Main scrollView */
@property (weak) IBOutlet NSScrollView *scrollView;

/** Every parameter of VSTimelineObject is displayed in its own view, which's controller is stored in parameterViewControllers*/
@property (strong) NSMutableArray *parameterViewControllers;

/** Wrapper for the VSParameterViews*/
@property (weak) IBOutlet NSView *parametersHolder;

/** label for the name of timelineObject */
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *nameTextField;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

@end
