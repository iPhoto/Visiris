//
//  VSTimelinView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * VSTimelineViewDelegate implements methods called in VSTimelineView
 */
@protocol VSTimelineViewDelegate <NSObject>

/**
 * Method is called when VSTimelineView was resized.
 * @param fromWidth Widht of the VSTimelineView's frame before it was resized.
 * @param toWidth New widht of the VSTimelineView's frame.
 */
-(void) viewDidResizeFromWidth:(NSInteger) fromWidth toWidth:(NSInteger) toWidth;

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
@property id<VSTimelineViewDelegate> delegate;

@end
