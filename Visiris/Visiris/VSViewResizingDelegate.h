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
@protocol VSViewResizingDelegate <NSObject>

@optional

/**
 * Called when the frame of the view was changes.
 *
 *@param view NSView which's frame was changed
 *@param newRect NSRect the frame of the view was changed to.
 */
-(void) frameOfView:(NSView*) view wasSetFrom:(NSRect) oldRect to:(NSRect) newRect;

/*
 * Called when the view's viewDidEndLiveResize is called
 * @param view NSView which did call the method
 */
-(void) viewDidEndLiveResizing:(NSView*) view;

/*
 * Called when the view's viewWillStartLiveResize is called
 * @param view NSView which did call the method
 */
-(void) viewDidStartLiveResizin:(NSView*) view;

@end
