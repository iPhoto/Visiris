//
//  VSTimelineRulerView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Timecode Ruler of the Timeline
 * !!!! Please add mor here !!!
 */
@interface VSTimelineRulerView : NSRulerView

/** PixelTimeRatio of the timeline the rulerview represents the timecodes for */
@property double pixelTimeRatio;

@end
