//
//  VSPlaybackController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol VSPlaybackControllerDelegate <NSObject>

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

-(void) finishedRenderingTexture:(GLuint) theTexture forTimestamp:(double) theTimestamp;



@end
