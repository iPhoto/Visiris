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
#import "VSDisclosureView.h"

@class VSTimelineObject;
@class VSTestView;
@class VSDisclosureView;

/**
 * Subclass of NSViewController displaying the properties of a VSTimelineObject
 *
 * Creates a VSParameterViewController for everey parameter of its VSTimelineObject
 */
@interface VSTimelineObjectPropertiesViewController : NSViewController<NSSplitViewDelegate, VSScrollViewScrollingDelegate, VSParameterViewKeyFrameDelegate, VSKeyFrameEditingDelegate, VSDisclosureViewDelegate>

/** VSTimelineObject which properties VSTimelineObjectPropertiesViewController is representing */
@property (strong) VSTimelineObject*timelineObject;

#pragma mark - Init

@property (weak) IBOutlet NSLayoutConstraint *parametersDisclosureWrapperViewVerticalTopConstraint;
@property (weak) IBOutlet VSDisclosureView *parametersDisclosureView;

@property (weak) IBOutlet VSDisclosureView *deviceDisclosureView;


/** ScrollView's documentView */
@property (weak) IBOutlet NSSplitView *parametersHolderSplitView;

/** Wrapper for the view of the VSAnimationTimelineViewController */
@property (weak) IBOutlet NSView *animationTimelineHolder;

@property (weak) IBOutlet VSScrollView *leftScrollView;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;


/**
 * Called before the VSTimelineObjectPropertiesViewController is removed from superview. Tells its subviews to reset.
 */
-(void) reset;

@end
