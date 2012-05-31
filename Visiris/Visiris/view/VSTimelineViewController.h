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

@class VSTimeline;
@class VSTimelineRulerView;

@interface VSTimelineViewController : NSViewController<VSTrackViewControllerDelegate, VSTimelineViewDelegate>

/** NSScrollView holding the VSTrackViews representing the single tracks */
@property (weak) IBOutlet NSScrollView *scvTrackHolder;

/** DocumentView of scvTrackHolder*/
@property (weak) IBOutlet NSView *tracksHolderdocumentView;

/** Displaying the timecode above the tracks */
@property (strong) NSRulerView *rulerView;

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
