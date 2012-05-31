//
//  VSImageSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSImageSourceSupplier.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"
#import "VSProjectItem.h"

@implementation VSImageSourceSupplier
@synthesize image = _image;

-(NSImage *) getFrameForTimestamp:(double)aTimestamp{
    
    if (self.image == nil) {
        self.image = [[NSImage alloc] initWithContentsOfFile:self.timelineObject.sourceObject.projectItem.filePath];
    }
    
//    return [NSImage imageNamed:@"aaa.jpg"];
    return self.image;
}

@end
