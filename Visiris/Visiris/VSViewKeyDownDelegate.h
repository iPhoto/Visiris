//
//  VSViewKeyDownDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.09.12.
//
//

#import <Foundation/Foundation.h>

/**
 * Defines how a Subclass of NSView informs its delegate about keyDowns
 */
@protocol VSViewKeyDownDelegate <NSObject>

/**
 * Called when VSTimelineView received an keyDown-Event
 * @param theEvent NSEvent of the keyDown-Event
 */
-(void) view:(NSView*) view didReceiveKeyDownEvent:(NSEvent*) theEvent;

@end
