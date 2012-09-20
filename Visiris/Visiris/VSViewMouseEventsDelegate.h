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

-(void) mouseDown:(NSEvent*) theEvent onView:(NSView*) view;

-(NSPoint) view:(NSView*) view wantsToBeDraggedFrom:(NSPoint) fromPoint to:(NSPoint) toPoint;

@end
