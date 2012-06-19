//
//  VSPreProcessor.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSTimeline.h"

@class VSCoreReceptionist;

/**
 * The VSPreProcessor is the interface between the UI/Model and Core of Visiris. With the help of suppliers it process the data of the currently active VSTimelineObjects and hand it over to the Core.
 */
@interface VSPreProcessor : NSObject<VSTimelineTimelineObjectsDelegate>

/** The timeline is asked for currently active VStimelineObjects */
@property VSTimeline *timeline;

/** The VSCoreReceptionist is connection to to VSRenderCore. */
@property (strong) VSCoreReceptionist *renderCoreReceptionist;


#pragma  mark - Init

/**
 * Inits VSPreProcessor and connects it with the given timeline.
 * @param timeline VSTimeline the VSPreProcessor asks for the currently active VSTimelineObjects to send their VSCoreHandovers to VSCoreReceptionist
 * @return self
 */
-(id) initWithTimeline:(VSTimeline*) timeline;


#pragma mark - Methods

/**
 * Tells the VStimelineObjects which are active at the given timestamp to give back their current parameter- and image-data, so they VSPreProcessor can hand-over the data to the Core 
 * @param aTimestamp Timestamp the frame will be processed for.
 * @param aFrameSize Frame size the frame will be processed for.
 * @param playing Tells if currently is playing or scrubbing.
 */
- (void)processFrameAtTimestamp:(double)aTimestamp withFrameSize:(NSSize)aFrameSize isPlaying:(BOOL)playing;

@end
