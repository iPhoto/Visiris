//
//  VSFrameSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameSourceSupplier.h"
#import "VSProjectSettings.h"
#import "VisirisCore/VSImage.h"
#import "VSCoreServices.h"


@implementation VSFrameSourceSupplier

@synthesize vsImage = _vsImage;
#pragma mark - Methods

-(VSImage *) getFrameForTimestamp:(double)aTimestamp withPlayMode:(VSPlaybackMode)playMode{
    DDLogInfo(@"ERROR - getFrameForTimestamp in FrameSourceSupplier is called - dunno why...");
    return nil;
}



@end
