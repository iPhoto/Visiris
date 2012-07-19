//
//  VSPreviewView.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPreviewView.h"
#import "VSCoreServices.h"

@implementation VSPreviewView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void) resizeSubviewsWithOldSize:(NSSize)oldSize{
    DDLogInfo(@"resizeSubviewsWithOldSize");
}

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
    
    DDLogInfo(@"setting frame");
}

@end
