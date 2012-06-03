//
//  VSTimelineObjectView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimelineObjectView;

/**
 * Protocol for VSTimelineObjectViewDelegates. Methods are invoked by VSTimelineObjectView
 */
@protocol VSTimelineObjectViewDelegate <NSObject>

/**
 * Called by VSTimelineObjectView when i got Selected
 * @param timelineObjectview The View invoked the method.
 */
-(void) timelineObjectViewWasClicked:(VSTimelineObjectView*) timelineObjectView;

-(void) timelineObjectIsDragged:(VSTimelineObjectView*) timelineObjectView fromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

-(BOOL) timelineObjectViewWillStartDragging:(VSTimelineObjectView*) timelineObjectView;

-(void) timelineObjectDidStopDragging:(VSTimelineObjectView*) timelineObjectView;

@end

@class VSTimelineObject;

/**
 * View-Representation of an object on the timeline
 * 
 */
@interface VSTimelineObjectView : NSView

/** Delegate that is called like definend in VSTimelineObjectViewDelegate Protocol */
@property id<VSTimelineObjectViewDelegate> delegate;

/** if true, a frame is drawn around the view */
@property BOOL selected;

@property BOOL intersected;

@property NSRect intersectionRect;

@property BOOL temporary;

@end
