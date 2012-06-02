//
//  VSPlaybackController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Protocoll defining how VSPlaybackController talks to its delegate
 */
@protocol VSPlaybackControllerDelegate <NSObject>

/**
 * Called when VSPlaybackController has received the Texture for the timestamp
 * @param theTexture GLuint defining the newly rendered texture.
 * @param theTimestamp Timestamp the texture was rendered for
 */
-(void) texture:(GLuint) theTexture isReadyForTimestamp:(double) theTimestamp;

@end

@class VSPreProcessor;
@class VSTimeline;
@class VSPreviewViewController;


#import "VSPreviewViewController.h"

/**
 * VSPlaybackController start and controls playing of the Visiris Project. It tells the VSPreProcessor to process data for an specific-frame
 */
@interface VSPlaybackController : NSObject<VSPreviewViewControllerDelegate>

/** Delegate VSPlaybackController communicates like defined in VSPlaybackControllerDelegate Protocoll */
@property id<VSPlaybackControllerDelegate> delegate;

/** The VSPrePRrocess is called to process data for a specific timestamp. */
@property (readonly) VSPreProcessor *preProcessor;

/** The VSTimline is called when the current timestamp has changed. */
@property (readonly) VSTimeline *timeline;

/** The currently active TimeStamp */
@property double currentTimestamp;


/**
 * Inits the VSPlaybackController with the given VSPrePRrocessor and the given timeline.
 * @param preProcessor The VSPrePRrocess is called to process data for a specific timestamp.
 * @param timeline The VSTimline is called when the current timestamp has changed.
 * @return self
 */
-(id) initWithPreProcessor:(VSPreProcessor*) preProcessor timeline:(VSTimeline*) timeline;

/**
 * Starts playing the scene form currentTimestamp of VSPlaybackController
 */
-(void) startPlaybackFromCurrentTimeStamp;

/**
 * Stops the playback
 */
-(void) stopPlayback;


/**
 * Called when the texture for the given timestamp was rendered handsover the information to its delegate.
 * @param theTexture GLuint defining the texture for the given timeStamp
 * @param theTimestamp Timestamp the texture was render for
 */
-(void) didFinisheRenderingTexture:(GLuint) theTexture forTimestamp:(double) theTimestamp;

@end
