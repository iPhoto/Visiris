//
//  VSTimelineObjectViewIntersection.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSTimelineObjectViewController;

/**
 * Stores the intersection of an VSTimelineObjectViewController with another VSTimelineObjectViewController
 */
@interface VSTimelineObjectViewIntersection : NSObject

/** Stores where the intersectino happend */
@property NSRect rect;

/** VSTimelineObjectViewController which intersects */
@property VSTimelineObjectViewController* timelineObjectView;

/** Layer to draw the intersection above the timelineObjectView */
@property CALayer *layer;

/**
 * Inits the intersection for the given values
 * @param intersectedTimelineObjectView VSTimelineObjectViewController which intersects another VSTimelineObjectViewController
 * @param intersectionRect NSRect storing where the intersection happend
 * @return self
 */
-(id) initWithIntersectedTimelineObejctView:(VSTimelineObjectViewController*) intersectedTimelineObjectView intersectedAt:(NSRect) intersectionRect andLayer:(CALayer*)layer;

@end
