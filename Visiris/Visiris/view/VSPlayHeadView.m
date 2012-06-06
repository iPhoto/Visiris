//
//  VSPlayHeadView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlayHeadView.h"

#import "VSCoreServices.h"

@interface VSPlayHeadView()

@property NSRect knobRect;

@end

@implementation VSPlayHeadView

@synthesize knobHeight  = _knobHeight;
@synthesize knobRect    = _knobRect;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.knobRect = self.frame;
        [self updateKnobRect];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor blueColor] set];
    NSRectFill(dirtyRect);
    [[NSColor darkGrayColor] set];
    NSRectFill(self.knobRect);
    DDLogInfo(@"%@",NSStringFromRect(self.knobRect));
}

#pragma mark - Private Methods

-(void) updateKnobRect{
self.knobRect = NSMakeRect(0, self.frame.size.height-self.knobHeight, self.frame.size.width, self.knobHeight);
}

#pragma mark - Properties

-(void) setKnobHeight:(NSInteger)knobHeight{
    _knobHeight = knobHeight;
    [self updateKnobRect];
    
    [self setNeedsDisplay:YES];
}

-(NSInteger) knobHeight{
    return _knobHeight;
}



@end
