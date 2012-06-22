//
//  VSTimelineGuideLine.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Subclass of NSView displaying a guideline for the current position of the playhead in the timeline
 */
@interface VSTimelineGuideLine : NSView

/** start position of the guideLine */
@property NSPoint lineStartPoint;

@end
