
//  VSTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTrackViewController.h"
#import "VSMainTimelineView.h"
#import "VSTimelineViewController.h"
#import "VSMainTimelineScrollViewDocumentView.h"
#import "VSMainTimelineScrollView.h"


@class VSTimeline;
@class VSTimelineRulerView;
@class VSMainTimelineScrollViewDocumentView;
@class VSMainTimelineScrollView;
@class VSProjectItemController;
@class VSProjectItemRepresentationController;
@class VSDeviceManager;
@class VSDeviceRepresentation;

/**
 * Subclass of NSViewController responsible for displaying a VSTimeline.
 *
 * VSTimelineViewController holds a various number of VSTrackViewController representing the VSTracks of the VSTimeline and acts as delegate for the VSTrackViewControllers. 
 * !!!!!!Please add more here
 */
@interface VSMainTimelineViewController : VSTimelineViewController<VSTrackViewControllerDelegate>

/** VSTimelineScrollView holding the VSTrackViews representing the single tracks */
@property (weak) IBOutlet VSMainTimelineScrollView *scrollView;

/** VSTimeline the controller represents */
@property (weak) VSTimeline* timeline;

/** Ratio between the duration of the timeline and the pixel length of tracksHolderdocumentView */
@property double pixelTimeRatio;

/** Reference on the DeviceManager */
@property (strong) VSDeviceManager* deviceManager;

#pragma mark - Init

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSTimelineView)
 */
-(id) initWithDefaultNib;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSTimelineView) for the given timeline.
 * @param timeline The VSTimeline the VSTimelineViewController represents
 * @return self
 */
-(id) initWithDefaultNibAccordingForTimeline:(VSTimeline*)timeline projectItemController:(VSProjectItemController*) projectItemController projectionItemRepresentationController:(VSProjectItemRepresentationController*) projectItemRepresentationController andDeviceManager:(VSDeviceManager*) deviceManager;

@end
