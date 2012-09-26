//
//  VSPlaybackController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSOutputController.h"


#import "VSCoreServices.h"


@class VSPreProcessor;
@class VSTimeline;

/**
 * VSPlaybackController start and controls playing of the Visiris Project. It tells the VSPreProcessor to process data for an specific-frame
 */
@interface VSPlaybackController : NSObject

/** The VSPrePRrocess is called to process data for a specific timestamp. */
@property (readonly, weak) VSPreProcessor *preProcessor;

/** The VSTimline is called when the current timestamp has changed. */
@property (readonly, weak) VSTimeline *timeline;

/** The currently active TimeStamp */
@property double currentTimestamp;

/** Indicates if renderFramesForCurrentTimestamp was called after starting the DisplayLink or not. Neccessary to make sure a requested frame was rendered */
@property BOOL frameWasRender;

/** Current playbackMode as definend in VSPlaybackMode */
@property VSPlaybackMode playbackMode;


/**
 * Inits the VSPlaybackController with the given VSPrePRrocessor and the given timeline.
 * @param preProcessor The VSPrePRrocess is called to process data for a specific timestamp.
 * @param timeline The VSTimline is called when the current timestamp has changed.
 * @return self
 */
-(id) initWithPreProcessor:(VSPreProcessor*) preProcessor timeline:(VSTimeline*) timeline;

/**
 * Starts the playback
 */
-(void) play;

/**
 * Stops the playback
 */
-(void) stop;

/**
 * Called when the texture for the given timestamp was rendered handsover the information to its delegate.
 * @param theTexture GLuint defining the texture for the given timeStamp
 * @param theTimestamp Timestamp the texture was render for
 */
-(void) didFinisheRenderingTexture:(GLuint) theTexture forTimestamp:(double) theTimestamp;

/**
 * Tells the VSPreProcessor to render the frame for the currentTimestamp for given frame size
 */
- (void)renderFramesForCurrentTimestamp;

/**
 * Tells the VSPreProcessor to render the current frame again
 */
-(void) updateCurrentFrame;

@end
