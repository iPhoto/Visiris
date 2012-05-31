//
//  VSPostProcessor.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPostProcessor.h"

#import "VSCoreServices.h"

@implementation VSPostProcessor


#pragma mark - VSCoreReceptionistDelegate implementation

- (void)coreReceptionist:(VSCoreReceptionist *)theCoreReceptionist didFinishedRenderingFrameAtTimestamp:(double)aTimestamp withResultingFrame:(char *)theNewFrame
{
    DDLogInfo(@"core finished creating frame for timestame: %d", aTimestamp);
}

@end
