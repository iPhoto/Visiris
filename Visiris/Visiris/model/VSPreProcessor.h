//
//  VSPreProcessor.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSTimeline.h"

/**
 * Protocoll defines how VSPreProcessor informs it's delegate about newly to RenderCore added VSTimelineObjects or currently removed VStimelineObjects
 */
@protocol VSPreProcessorDelegate <NSObject>

/**
 * Called when a TimelineObjects were removed from the renderCore
 * 
 * @param timelineObjects NSArray of VSTimelineObjects removed from the renderCore
 */
-(void) removedTimelineObjectsfromRenderCore:(NSArray*) timelineObjects;

/**
 * Called when a TimelineObjects were added to the renderCore
 *
 * @param timelineObjects NSArray of VSTimelineObjects added to the renderCore
 */
-(void) addedTimelineObjectsToRenderCore:(NSArray*) timelineObjects;

@end

@class VSCoreReceptionist;

/**
 * The VSPreProcessor is the interface between the UI/Model and Core of Visiris. With the help of suppliers it process the data of the currently active VSTimelineObjects and hand it over to the Core.
 */
@interface VSPreProcessor : NSObject<VSTimelineTimelineObjectsDelegate>

/** The timeline is asked for currently active VStimelineObjects */
@property (weak) VSTimeline *timeline;

/** The VSCoreReceptionist is connection to to VSRenderCore. */
@property (weak) VSCoreReceptionist *renderCoreReceptionist;

/** Delegate the VSPreProcessor talks to when timelinObjects were added to or remove from the VSRenderCore as definend in VSPreProcessorDelegate protocoll */
@property (weak) id<VSPreProcessorDelegate> delegate;

#pragma  mark - Init

/**
 * Inits VSPreProcessor and connects it with the given timeline.
 * @param timeline VSTimeline the VSPreProcessor asks for the currently active VSTimelineObjects to send their VSCoreHandovers to VSCoreReceptionist
 * @return self
 */
-(id)initWithTimeline:(VSTimeline *)timeline andCoreReceptionist:(VSCoreReceptionist*) coreReceptionist;

#pragma mark - Methods

/**
 * Tells the VStimelineObjects which are active at the given timestamp to give back their current parameter- and image-data, so they VSPreProcessor can hand-over the data to the Core 
 * @param aTimestamp Timestamp the frame will be processed for.
 * @param aFrameSize Frame size the frame will be processed for.
 * @param playMode Currently Playing Mode as defined in VSPlaybackMode
 */
- (void)processFrameAtTimestamp:(double)aTimestamp withFrameSize:(NSSize)aFrameSize withPlayMode:(VSPlaybackMode)playMode;

/**
 * Tells the core to stop 
 */
- (void)stopPlayback;

@end
