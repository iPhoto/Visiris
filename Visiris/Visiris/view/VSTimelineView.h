//
//  VSTimelinView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSViewMouseEventsDelegate.h"
#import "VSViewResizingDelegate.h"
#import "VSViewKeyDownDelegate.h"


/**
 * VSTimelineView is the view for VSTimeline
 */
@interface VSTimelineView : NSView

/** Delegate confirming to VSTimelineViewDelegate */
@property id<VSViewResizingDelegate> resizingDelegate;

/** Delegate VSTimelineView informs about mouseEvents as definined in VSViewMouseEventsDelegate-Protocoll */
@property id<VSViewMouseEventsDelegate> mouseMoveDelegate;

/** Delegate VSTimelineView informs about keyDownEvens as definend in VSViewKeyDownDelegate-Protocoll */
@property id<VSViewKeyDownDelegate> keyDownDelegate;

@end
