//
//  VSTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTrackViewController.h"
#import "VStimelineView.h"
#import "VSTrackHolderView.h"
#import "VSTimelineScrollView.h"
#import "VSViewMouseEventsDelegate.h"

@class VSTimeline;
@class VSTimelineRulerView;
@class VSTrackHolderView;
@class VSTimelineScrollView;

/**
 * Subclass of NSViewController responsible for displaying a VSTimeline.
 *
 * VSTimelineViewController holds a various number of VSTrackViewController representing the VSTracks of the VSTimeline and acts as delegate for the VSTrackViewControllers. 
 * !!!!!!Please add more here
 */
@interface VSTimelineViewController : NSViewController<VSTrackViewControllerDelegate, VSTimelineViewDelegate, VSPlayHeadRulerMarkerDelegate,VSTimelineScrollViewZoomingDelegate, VSViewMouseEventsDelegate>

/** VSTimelineScrollView holding the VSTrackViews representing the single tracks */
@property (weak) IBOutlet VSTimelineScrollView *scrollView;

/** VSTimeline the controller represents */
@property VSTimeline* timeline;

/** Ratio between the duration of the timeline and the pixel length of tracksHolderdocumentView */
@property double pixelTimeRatio;

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
-(id) initWithDefaultNibAccordingForTimeline:(VSTimeline*)timeline;

@end
