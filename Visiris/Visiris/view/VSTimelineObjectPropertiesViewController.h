//
//  VSTimelineObjectPropertiesControllerViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimelineObject;

/**
 * Subclass of NSViewController displaying the properties of a VSTimelineObject
 *
 * Creates a VSParameterViewController for everey parameter of its VSTimelineObject
 */
@interface VSTimelineObjectPropertiesViewController : NSViewController

/** VSTimelineObject which properties VSTimelineObjectPropertiesViewController is representing */
@property VSTimelineObject *timelineObject;

#pragma mark - Init
/** ScrollView's documentView */
@property (weak) IBOutlet NSView *documentView;

/** Main scrollView */
@property (weak) IBOutlet NSScrollView *scrollView;

/** Wrapper for the VSParameterViews*/
@property (weak) IBOutlet NSView *parametersHolder;

/** label for the name of VSTimelineObject */
@property (weak) IBOutlet NSTextField *nameLabel;

/** Textfield for the name of VSTimelineObject */
@property (weak) IBOutlet NSTextField *nameTextField;

/** Every parameter of VSTimelineObject is displayed in its own view, which's controller is stored in parameterViewControllers*/
@property (strong) NSMutableArray *parameterViewControllers;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;
- (IBAction)nameTextFieldHasChanged:(NSTextField *)sender;

@end
