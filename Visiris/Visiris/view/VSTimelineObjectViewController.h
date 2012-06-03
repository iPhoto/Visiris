//
//  VSTimelineObjectViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineObjectView.h"

@class VSTimelineObjectProxy;
@class VSTimelineObjectViewController;

/**
 * Protocoll that defines how VSTimelineObjectViewController talks to its delegate 
 *
 */
@protocol VSTimelineObjectControllerDelegate <NSObject>

/**
 * Called when a VSTimelineObjectView was selected by the user on the timeline
 * @param timelineObjectProxy VSTimelineObjectProxy the clicked VSTimelineObjectView represents
 * @return YES if the VSTimelineObjectView is allowed to get selected, NO otherwise
 */
-(BOOL) timelineObjectProxyWillBeSelected:(VSTimelineObjectProxy*) timelineObjectProxy;

-(void) timelineObjectProxyWasSelected:(VSTimelineObjectProxy*) timelineObjectProxy;

-(void) timelineObjectProxyWasUnselected:(VSTimelineObjectProxy*) timelineObjectProxy;

-(void) timelineObjectIsDragged:(VSTimelineObjectViewController*) timelineObjectViewController fromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

-(BOOL) timelineObjectWillStartDragging:(VSTimelineObjectViewController*) timelineObjectViewController;

-(void) timelineObjectDidStopDragging:(VSTimelineObjectViewController*) timelineObjectViewController;


@end

/**
 * VSTimelineObjectViewController is responsible for displaying a VSTimelineObjectProxy representing a VSTimelineObject.
 */
@interface VSTimelineObjectViewController : NSViewController<VSTimelineObjectViewDelegate>

/** Called according to VSTimelineObjectControllerDelegate protocoll */
@property id<VSTimelineObjectControllerDelegate> delegate;

/** VSTimelineObjectProxy of the VSTimelineObject the VSTimelineObjectViewController represents*/
@property (strong) VSTimelineObjectProxy* timelineObjectProxy;

@property BOOL intersected;

@property NSRect intersectionRect;

@property BOOL enteredLeft;

@property BOOL temporary;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;


#pragma mark - Methods

-(void) changePixelTimeRatio:(double) newPixelTimeRatio;

@end
