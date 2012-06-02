//
//  VSPostProcessor.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPostProcessor.h"
#import "VSPlaybackController.h"
#import "VSCoreServices.h"

@interface VSPostProcessor()

@property VSPlaybackController *playbackController;
@end

@implementation VSPostProcessor

/** VSPlaybackController the VSPostProcessor calls when the rendering of the texture has finished by the core */
@synthesize playbackController = _playbackController;

#pragma mark - Init

-(id) initWithPlaybackController:(VSPlaybackController *)thePlaybackController{
    if(self = [super init]){
        self.playbackController = thePlaybackController;
    }
    return self;
}

#pragma mark - VSCoreReceptionistDelegate implementation

- (void)coreReceptionist:(VSCoreReceptionist *)theCoreReceptionist didFinishedRenderingFrameAtTimestamp:(double)theTimestamp withResultingTexture:(GLuint)theTexture
{
    [self.playbackController didFinisheRenderingTexture:theTexture forTimestamp:theTimestamp];
}

@end
