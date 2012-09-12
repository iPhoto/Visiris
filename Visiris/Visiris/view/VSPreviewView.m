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

@synthesize frameResizingDelegate   = _frameResizingDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(void) awakeFromNib{
    
}

-(void) setFrame:(NSRect)frameRect{
    NSRect oldFrame = self.frame;
    
    [super setFrame:frameRect];
    
    //tells its delegate that the view's frame was resized
    if(self.frameResizingDelegate){
        if([self.frameResizingDelegate conformsToProtocol:@protocol(VSViewResizingDelegate)]){
            if([self.frameResizingDelegate respondsToSelector:@selector(frameOfView:wasSetFrom:to:)]){
                [self.frameResizingDelegate frameOfView:self wasSetFrom:oldFrame to:self.frame];
            }
        }
    }
}

@end
