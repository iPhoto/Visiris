//
//  VSPreviewViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSCoreServices.h"
#import "VSPreviewOpenGLView.h"

@class VSPlaybackController;

#import "VSPlaybackController.h"
#import "VSViewResizingDelegate.h"

/**
 * Subclass of NSViewController responsible for the Previw at the top-right of the window
 */
@interface VSPreviewViewController : NSViewController<VSPlaybackControllerDelegate, VSViewResizingDelegate>

@property (strong) NSOpenGLContext *openGLContext;

/** Reference to the VSPlaybackController. Its called to start / stop the playback of the project */
@property VSPlaybackController *playbackController;

/** VSPreviewOpenGLView showing the the content of the openGLContext */
@property (weak) IBOutlet VSPreviewOpenGLView *openGLView;

/** NSView wrapping VSPreviewOpenGLView */ 
@property (weak) IBOutlet NSView *openGLViewHolder;

//TODO COMMENT
@property (readonly) uint64_t hostTime;

//TODO COMMENT
@property (readonly) double refreshPeriod;

#pragma mark - init

/**
 * Inits the view with the defaultNib and sets the given NSOpenGLContext
 * @param theOpenGLContext NSOpenGLContext to be displayed in openGLView
 * @return Returns self
 */
-(id) initWithDefaultNibForOpenGLContext:(NSOpenGLContext*) theOpenGLContext;


#pragma mark - IBAction

/**
 * Called when the play-Button is clicked
 * @param sender NSButton which has called the action
 * @return IBAction
 */
- (IBAction)play:(NSButton *)sender;

/**
 * Called when the stop-Button is clicked
 * @param sender NSButton which has called the action
 * @return IBAction
 */
- (IBAction)stop:(NSButton *)sender;

/**
 * Called when the Slider controlling the Framerate
 * @param sender Control which has called the action
 * @return IBAction
 */
- (IBAction)frameRateSliderHasChanged:(NSSlider *)sender;

@end
