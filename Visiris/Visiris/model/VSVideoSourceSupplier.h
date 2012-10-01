//
//  VSVideoSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameSourceSupplier.h"

/**
 * Supplier for VSTimelineObjects with VSVideoSources
 */
@interface VSVideoSourceSupplier : VSFrameSourceSupplier

/** Flag if Video has a Audioline */
@property (assign) BOOL     hasAudio;

/** Timestamp of the video - different to localtimestamp because of looping */
@property (assign) double   videoTimestamp;

@end
