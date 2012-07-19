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
#import "VSProjectSettings.h"

@interface VSPlaybackController()

/** Times the playback */
@property NSTimer *playbackTimer;

@property (strong) NSOperationQueue *queue;
@property BOOL playing;
@property double playbackStartTime;
@property BOOL jumping;

@end

@implementation VSPlaybackController

@synthesize preProcessor        = _preProcessor;
@synthesize timeline            = _timeline;
@synthesize currentTimestamp    = _currentTimestamp;
@synthesize playbackTimer       = _playbackTimer;
@synthesize delegate            = _delegate;
@synthesize queue               = _queue;
@synthesize playing             = _playing;
@synthesize playbackStartTime   = _playbackStartTime;
@synthesize frameWasRender      = _frameWasRender;
@synthesize jumping             = _jumping;

#pragma mark - Init

-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        _preProcessor = preProcessor;
        _timeline = timeline;
        self.queue = [[NSOperationQueue alloc] init];
        
        [self.timeline.playHead addObserver:self forKeyPath:@"currentTimePosition" options:0 context:nil];
        [self.timeline.playHead addObserver:self forKeyPath:@"scrubbing" options:0 context:nil];
        [self.timeline.playHead addObserver:self forKeyPath:@"jumping" options:0 context:nil];
    }
    
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"currentTimePosition"]){
        if(!self.playing && !self.timeline.playHead.scrubbing && !self.timeline.playHead.jumping){
            self.currentTimestamp = [[object valueForKey:keyPath] doubleValue];
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
    }
    
    else if([keyPath isEqualToString:@"jumping"]){
        if([[object valueForKey:keyPath] boolValue]){
            self.jumping = YES;
            
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
    }
    
    else if([keyPath isEqualToString:@"scrubbing"]){
        BOOL scrubbing = [[object valueForKey:keyPath] boolValue];
        
        self.currentTimestamp = [[object valueForKey:@"currentTimePosition"] doubleValue];
        
        if(scrubbing){
            self.playing = NO;
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
        else{
            if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
                [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
    }
    
}

#pragma mark - Methods

- (void)startPlaybackFromCurrentTimeStamp
{
    //    [self startTimer];
    NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil]; //Create a new thread
    [timerThread start];
}

//TODO WTF??? isnt called anymore
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
    
    if(self.jumping){
        if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
            [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
        }
    self.jumping = NO;
    }
}

- (void)renderFramesForCurrentTimestamp{
    if(self.playing){
        [self computeNewCurrentTimestamp];
    }
    
    [self renderCurrentFrame];
}

-(void) renderCurrentFrame{
    if (self.preProcessor) {
        [self.preProcessor processFrameAtTimestamp:self.timeline.playHead.currentTimePosition withFrameSize:[VSProjectSettings sharedProjectSettings].frameSize isPlaying:self.playing];
    }
    
    if(!self.playing){
        if(!self.timeline.playHead.scrubbing){
            if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
                [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
            }
            self.frameWasRender = YES;
            
            
        }
    }
}

-(void) computeNewCurrentTimestamp{
    double currentTime = [[NSDate date] timeIntervalSince1970]*1000;        
    
    self.currentTimestamp += currentTime - self.playbackStartTime;
    
    if(self.currentTimestamp > self.timeline.duration){
        self.currentTimestamp = 0;
    }
    
    self.timeline.playHead.currentTimePosition = self.currentTimestamp;
    self.playbackStartTime = currentTime;
}

#pragma mark - VSPreviewViewControllerDelegate implementation

-(void) play{
    //    [self startPlaybackFromCurrentTimeStamp];
    self.playing = YES;
    
    self.playbackStartTime = [[NSDate date] timeIntervalSince1970]*1000;
}

-(void) stop{
    //    [self stopPlayback];
    self.playing = NO;
    [self.preProcessor stopPlayback];
}


#pragma mark - Private Methods

//TODO who needs this?
-(void) startTimer{
    @autoreleasepool {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        //Fire timer every second to updated countdown and date/time
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(renderFramesForCurrentTimestamp) userInfo:nil repeats:YES] ;
        [runLoop run];
    }
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

@end
