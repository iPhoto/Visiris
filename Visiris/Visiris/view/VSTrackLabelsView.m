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
    [[NSColor lightGrayColor] set];
    NSRectFill(dirtyRect);
    
    [[NSColor darkGrayColor] set];
    for(VSTrackLabel *trackLabel in self.trackLabels){
        NSRectFill(trackLabel.frame);
        [trackLabel.name drawInRect:trackLabel.frame withAttributes:nil];
    }
}

@end
