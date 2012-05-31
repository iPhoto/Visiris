//
//  VSCoreReceptionist.m
//  VisirisCore
//
//  Created by Andreas Schacherbauer on 5/16/12.
//  Copyright (c) 2012 DevaStation. All rights reserved.
//

#import "VSCoreReceptionist.h"


@implementation VSCoreReceptionist
@synthesize renderCore = _renderCore;
@synthesize delegate=_delegate;

-(id) init{
    if(self = [super init]){
        self.renderCore = [[VSRenderCore alloc] init];
        self.renderCore.delegate = self;
    }
    return self;
}

- (void)renderFrameAtTimestamp:(double)aTimestamp withHandovers:(NSArray *)theHandovers forSize:(NSSize)theFrameSize
{
    if (theHandovers) {
                
        [self.renderCore renderFrameOfCoreHandovers:theHandovers forFrameSize:theFrameSize forTimestamp:aTimestamp];
    }
}

#pragma mark - RenderCoreDelegate impl.

- (void)renderCore:(VSRenderCore *)theRenderCore didFinishRenderingFrame:(char *)theFinalFrame forTimestamp:(double)theTimestamp
{
    if (self.delegate) { 
        if ([self.delegate respondsToSelector:(@selector(coreReceptionist:didFinishedRenderingFrameAtTimestamp:withResultingFrame:))]) {
            [self.delegate coreReceptionist:self didFinishedRenderingFrameAtTimestamp:1.0 withResultingFrame:nil];
        }
    }
}

- (NSOpenGLContext *) openGLContext{
    return _renderCore.openGLContext;
}

@end
