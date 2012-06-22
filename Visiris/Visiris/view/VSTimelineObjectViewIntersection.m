//
//  VSTimelineObjectViewIntersection.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectViewIntersection.h"

@implementation VSTimelineObjectViewIntersection

@synthesize intersectionRect                = _intersectionRect;
@synthesize intersectedTimelineObjectView   = _intersectedTimelineObjectView;

-(id) initWithIntersectedTimelineObejctView:(VSTimelineObjectViewController *)intersectedTimelineObjectView intersectedAt:(NSRect)intersectionRect{
    if(self = [super init]){
        self.intersectionRect = intersectionRect;
        self.intersectedTimelineObjectView = intersectedTimelineObjectView;
    }
    return self;
}

@end
