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
#import "VSPlayHead.h"

@interface VSPlaybackController()

/** Times the playback */
@property NSTimer *playbackTimer;

@property (strong) NSOperationQueue *queue;
@property BOOL playing;

@end

@implementation VSPlaybackController

@synthesize preProcessor        = _preProcessor;
@synthesize timeline            = _timeline;
@synthesize currentTimestamp    = _currentTimestamp;
@synthesize playbackTimer       = _playbackTimer;
@synthesize delegate            = _delegate;
@synthesize queue               = _queue;
@synthesize playing             = _playing;

#pragma mark - Init

-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        _preProcessor = preProcessor;
        _timeline = timeline;
        self.queue = [[NSOperationQueue alloc] init];
        [self.timeline.playHead addObserver:self forKeyPath:@"currentTimePosition" options:0 context:nil];
    }
    
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"currentTimePosition"]){
        double timePos = [[object valueForKey:keyPath] doubleValue];
        
      //  [self.preProcessor processFrameAtTimestamp:timePos withFrameSize:NSMakeSize(1024, 768)];

    }
}

#pragma mark - Methods

- (void)startPlaybackFromCurrentTimeStamp
{
//    [self startTimer];
    NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil]; //Create a new thread
    [timerThread start];
}

-(void) stopPlayback{
    [self.queue cancelAllOperations];
    [self.playbackTimer invalidate];
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

- (void)renderFramesForCurrentTimestamp
{
    if(self.playing){
        
        if (self.preProcessor) {
            [self.preProcessor processFrameAtTimestamp:self.timeline.playHead.currentTimePosition withFrameSize:[self frameSize]];
        }
        
        //    [self.queue addOperationWithBlock:^{
        //        [self.preProcessor processFrameAtTimestamp:0 withFrameSize:NSMakeSize(120, 120)];
        //    }];
    }
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

-(void) startTimer{
    @autoreleasepool {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        //Fire timer every second to updated countdown and date/time
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(renderFramesForCurrentTimestamp) userInfo:nil repeats:YES] ;
        [runLoop run];
    }
}

@end
