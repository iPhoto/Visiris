//
//  VSViewMouseEventsDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Defines how a NSView informs a delegate about MouseEvents
 */
@protocol VSViewMouseEventsDelegate <NSObject>

@optional

/**
 * Called when the mouse was moved on the NSView
 *
 * @param theEvent NSEvent of the mouseMoved-Event
 * @param view NSView the mouse was moved on
 */
-(void) mouseMoved:(NSEvent*) theEvent onView:(NSView*) view;

/**
 * Called when the mouse was dragged on the NSView
 *
 * @param theEvent NSEvent of the mouseDragged-Event
 * @param view NSView the mouse was dragged on
 */
-(void) mouseDragged:(NSEvent*) theEvent onView:(NSView*) view;

/**
 * Called when a mouseDown on an NSView happend
 * @param theEvent NSEvent of the mouseDown-Event
 * @param view NSView the mouse was pressed down on
 */
-(void) mouseDown:(NSEvent*) theEvent onView:(NSView*) view;

/**
 * Called when a mouseUp on an NSView happend
 * @param theEvent NSEvent of the mouseUp-Event
 * @param view NSView the mouse was released on
 */
-(void) mouseUp:(NSEvent*) theEvent onView:(NSView*) view;

/**
 * Called when a rightMouseDown-Event on an NSView happend
 * @param theEvent NSEvent of the rightMouseDown-Event
 * @param view NSView the mouse was pressed down on
 */
-(void) rightMouseDown:(NSEvent*) theEvent onView:(NSView*) view;

/**
 * Called when a view wants to be draggged around by the mouse in its mouseDragged-Event
 * @param view View that wants to be dragged
 * @param fromPoint Current origin of the frame
 * @param toPoint Point the origin of the frame wants to be changed to
 * @return NSPoint the origin of the frame will be changed to
 */
-(NSPoint) view:(NSView*) view wantsToBeDraggedFrom:(NSPoint) fromPoint to:(NSPoint) toPoint;

@end
