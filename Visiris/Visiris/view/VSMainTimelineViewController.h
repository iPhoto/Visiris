//
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
#import "VSMainTimelineContentView.h"
#import "VSMainTimelineScrollView.h"


@class VSTimeline;
@class VSTimelineRulerView;
@class VSMainTimelineContentView;
@class VSMainTimelineScrollView;

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

/**
 * Computes the new currentTimePosition of the timeline's playhead after the playhead-marker would have been moved the given distance, updates the currentTimePosition and sets the playhead's jumping-flag to YES
 * @param distance Distance the Playhead will be moved
 */
-(void) letPlayheadJumpOverDistance:(float) distance;

@end
