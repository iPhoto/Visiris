//
//  VSFrameResizingDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 19.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Defines how a NSView informs its delegate about changes on its frame
 */
@protocol VSFrameResizingDelegate <NSObject>

/**
 * Called when the frame of the view was changes.
 *
 *@param view NSView which's frame was changed
 *@param newRect NSRect the frame of the view was changed to.
 */
-(void) frameOfView:(NSView*) view wasSetTo:(NSRect) newRect;

@end
