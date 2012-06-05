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

/** Times the playback */
@property NSTimer *playbackTimer;

@property (strong) NSOperationQueue *queue;
@property BOOL playing;

@end

@implementation VSPlaybackController

@synthesize preProcessor = _preProcessor;
@synthesize timeline = _timeline;
@synthesize currentTimestamp = _currentTimestamp;
@synthesize playbackTimer = _playbackTimer;
@synthesize delegate = _delegate;
@synthesize queue = _queue;
@synthesize playing = _playing;

#pragma mark - Init

-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        _preProcessor = preProcessor;
        _timeline = timeline;
        self.queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

#pragma mark - Methods

- (void)startPlaybackFromCurrentTimeStamp
{
//    [self startTimer];
    NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil]; //Create a new thread
    [timerThread start];
}

-(void) startTimer{
    @autoreleasepool {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        //Fire timer every second to updated countdown and date/time
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(renderFramesForCurrentTimestamp) userInfo:nil repeats:YES] ;
        [runLoop run];
    }
}

-(void) stopPlayback{
    [self.queue cancelAllOperations];
    [self.playbackTimer invalidate];
}

#pragma mark - VSPreviewViewControllerDelegate implementation

-(void) play{
//    [self startPlaybackFromCurrentTimeStamp];
    self.playing = YES;
}

-(void) stop{
//    [self stopPlayback];
    self.playing = NO;
}


#pragma mark - Private Methods

/**
 * Test function to return a valid frameSize
 */
- (NSSize)frameSize
{
    return NSMakeSize(1280, 720);
}


- (void)renderFramesForCurrentTimestamp
{
    if(self.playing){
    
    if (self.preProcessor) {
        [self.preProcessor processFrameAtTimestamp:self.currentTimestamp withFrameSize:[self frameSize]];
    }
    
//    [self.queue addOperationWithBlock:^{
//        [self.preProcessor processFrameAtTimestamp:0 withFrameSize:NSMakeSize(120, 120)];
//    }];
    }
}



-(void) didFinisheRenderingTexture:(GLuint)theTexture forTimestamp:(double)theTimestamp{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate) ]){
            if([self.delegate respondsToSelector:@selector(texture:isReadyForTimestamp:)]){
                [self.delegate texture:theTexture isReadyForTimestamp:theTimestamp];
            }
        }
    }
}

@end
