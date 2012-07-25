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
    [super setFrame:frameRect];
    
    //tells its delegate that the view's frame was resized
    if(self.frameResizingDelegate){
        if([self.frameResizingDelegate conformsToProtocol:@protocol(VSFrameResizingDelegate)]){
            if([self.frameResizingDelegate respondsToSelector:@selector(frameOfView:wasSetTo:)]){
                [self.frameResizingDelegate frameOfView:self wasSetTo:frameRect];
            }
        }
    }
}

@end
