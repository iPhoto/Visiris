//
//  VSPlaybackController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlaybackController.h"
#import "VSPreProcessor.h"
#import "VSTimeline.h"
#import "VSPreviewViewController.h"

@interface VSPlaybackController()

@property NSTimer *playbackTimer;

@end

@implementation VSPlaybackController

@synthesize preProcessor = _preProcessor;
@synthesize timeline = _timeline;
@synthesize currentTimestamp = _currentTimestamp;
@synthesize playbackTimer = _playbackTimer;
@synthesize delegate = _delegate;

-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        _preProcessor = preProcessor;
        _timeline = timeline;
        
    }
    
    return self;
}


- (void)startPlaybackFromCurrentTimeStamp
{
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(renderFramesForCurrentTimestamp) userInfo:nil repeats:YES];
}

-(void) stopPlayback{
    [self.playbackTimer invalidate];
}

#pragma mark - Private Methods


- (NSSize)frameSize
{
    return NSMakeSize(1280, 720);
}


/**
 * Tells the VSPreProcessor to render the frame for the currentTimestamp for given frame size
 */
- (void)renderFramesForCurrentTimestamp
{
    if (self.preProcessor) {
        [self.preProcessor processFrameAtTimestamp:self.currentTimestamp withFrameSize:[self frameSize]];
    }
}

-(void) finishedRenderingTexture:(GLuint)theTexture forTimestamp:(double)theTimestamp{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate) ]){
            if([self.delegate respondsToSelector:@selector(texture:isReadyForTimestamp:)]){
                [self.delegate texture:theTexture isReadyForTimestamp:theTimestamp];
            }
        }
    }
}

#pragma mark - VSPreviewViewControllerDelegate implementation

-(void) play{
    [self startPlaybackFromCurrentTimeStamp];
}

-(void) stop{
    [self stopPlayback];
}

@end
