//
//  VSTimelineObjectProxy.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 14.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectProxy.h"

@implementation VSTimelineObjectProxy
@synthesize startTime = _startTime;
@synthesize duration = _duration;
@synthesize name = _name;
@synthesize icon = _icon;
@synthesize selected = _selected;

#pragma mark- Init

-(id) initWithName:(NSString *)name atTime:(double)startTime duration:(double)duration icon:(NSImage *)icon{
    if(self = [super init]){
        self.startTime = startTime;
        self.duration = duration;
        self.icon = icon;
        self.name = name;
        self.selected = NO;
    }
    
    return self;
}
@end
