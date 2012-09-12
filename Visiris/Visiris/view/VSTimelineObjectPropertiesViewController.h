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

@class VSTimelineObject;
@class VSTestView;

/**
 * Subclass of NSViewController displaying the properties of a VSTimelineObject
 *
 * Creates a VSParameterViewController for everey parameter of its VSTimelineObject
 */
@interface VSTimelineObjectPropertiesViewController : NSViewController<NSSplitViewDelegate, VSFrameResizingDelegate, VSScrollViewScrollingDelegate>

/** VSTimelineObject which properties VSTimelineObjectPropertiesViewController is representing */
@property VSTimelineObject *timelineObject;

#pragma mark - Init
/** ScrollView's documentView */

@property (weak) IBOutlet NSSplitView *splitView;

/** Wrapper for the VSParameterViews*/
@property (weak) IBOutlet NSView *parametersHolder;

@property (weak) IBOutlet NSView *animationTimelineHolder;

/** label for the name of VSTimelineObject */
@property (strong) NSTextField *nameLabel;

/** Textfield for the name of VSTimelineObject */
@property (strong) NSTextField *nameTextField;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

- (IBAction)nameTextFieldHasChanged:(NSTextField *)sender;

@end
