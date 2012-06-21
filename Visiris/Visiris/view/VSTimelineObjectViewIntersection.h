//
//  VSTimelineObjectViewIntersection.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSTimelineObjectViewController;

@interface VSTimelineObjectViewIntersection : NSObject

@property NSRect intersectionRect;
@property VSTimelineObjectViewController* intersectedTimelineObjectView;

-(id) initWithIntersectedTimelineObejctView:(VSTimelineObjectViewController*) intersectedTimelineObjectView intersectedAt:(NSRect) intersectionRect;

@end
