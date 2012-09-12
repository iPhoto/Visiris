//
//  VSViewKeyDownDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.09.12.
//
//

#import <Foundation/Foundation.h>

@protocol VSViewKeyDownDelegate <NSObject>

/**
 * Called when VSTimelineView received an keyDown-Event
 * @param theEvent NSEvent of the keyDown-Event
 */
-(void) didReceiveKeyDownEvent:(NSEvent*) theEvent;

@end
