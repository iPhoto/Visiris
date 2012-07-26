//
//  VSTimelineRulerView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineRulerView.h"

#import "VSCoreServices.h"

@implementation VSTimelineRulerView
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

-(void) drawHashMarksAndLabelsInRect:(NSRect)rect{
    DDLogInfo(@"drawHashMarksAndLabelsInRect");
}

-(void) drawRect:(NSRect)dirtyRect{
    DDLogInfo(@"drawrect");
}

-(void) drawMarkersInRect:(NSRect)rect{
    DDLogInfo(@"drawMarkersInREct");
}

-(void) invalidateHashMarks{
    DDLogInfo(@"invali");
}

-(void) setMeasurementUnits:(NSString *)unitName{
    DDLogInfo(@"setMeasurementUnits");
}

@end
