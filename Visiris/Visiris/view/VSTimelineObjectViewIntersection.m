//
//  VSTimelineObjectViewIntersection.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectViewIntersection.h"

@implementation VSTimelineObjectViewIntersection

@synthesize rect                = _rect;
@synthesize timelineObjectView  = _timelineObjectView;
@synthesize layer               = _layer;

-(id) initWithIntersectedTimelineObejctView:(VSTimelineObjectViewController *)intersectedTimelineObjectView intersectedAt:(NSRect)intersectionRect andLayer:(CALayer*)layer{
    if(self = [super init]){
        self.rect = intersectionRect;
        self.timelineObjectView = intersectedTimelineObjectView;
        self.layer = layer;
    }
    return self;
}

@end
