//
//  VSTrackLabelsView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackLabelsView.h"

#import "VSTrackLabel.h"

#import "VSCoreServices.h"

@implementation VSTrackLabelsView

@synthesize trackLabels = _trackLabels;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.trackLabels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    
}

-(void) drawHashMarksAncdLabelsInRect:(NSRect)rect{
    DDLogInfo(@"drawHashMarksAndLabelsInRect");
    [[NSColor redColor] set];
    for(VSTrackLabel *trackLabel in self.trackLabels){
        DDLogInfo(@"hier");
        NSRectFill(trackLabel.frame);
        [trackLabel.name drawInRect:trackLabel.frame withAttributes:nil];
    }
}

@end
