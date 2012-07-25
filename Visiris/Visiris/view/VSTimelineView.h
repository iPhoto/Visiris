//
//  VSTimelinView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSViewMouseEventsDelegate.h"

/**
 * VSTimelineViewDelegate implements methods called in VSTimelineView
 */
@protocol VSTimelineViewDelegate <NSObject>

/**
 * Method is called when VSTimelineView was resized.
 */
-(void) viewDidResizeFromFrame:(NSRect) oldFrame toFrame:(NSRect) newFrame;

/**
 * Called when VSTimelineView received an keyDown-Event
 * @param theEvent NSEvent of the keyDown-Event
 */
-(void) didReceiveKeyDownEvent:(NSEvent*) theEvent;
@end

/**
 * VSTimelineView is the view for VSTimeline
 */
@interface VSTimelineView : NSView

/** Delegate confirming to VSTimelineViewDelegate */
@property id<VSTimelineViewDelegate> timelineViewDelegate;

/** Delegate VSTimelineView informs about mouseEvents as definined in VSViewMouseEventsDelegate-Protocoll */
@property id<VSViewMouseEventsDelegate> mouseMoveDelegate;


@end
