//
//  VSTestView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTestView.h"

@implementation VSTestView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] set];
    NSRectFill(dirtyRect);
}
-(BOOL) isFlipped{
    return NO;
}

-(void) viewDidUnhide{
    
}

-(void) viewDidHide{
    
}

@end
