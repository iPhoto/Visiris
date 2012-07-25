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

/** Timestamp when the playback was started */
@property double playbackStartTime;

/** Current playbackMode as definend in VSPlaybackMode */
@property VSPlaybackMode playbackMode;

@property VSPreProcessor* preProcessor;

@property VSTimeline* timeline;
@end

@implementation VSPlaybackController

@synthesize preProcessor        = _preProcessor;
@synthesize timeline            = _timeline;
@synthesize currentTimestamp    = _currentTimestamp;
@synthesize playbackTimer       = _playbackTimer;
@synthesize delegate            = _delegate;
@synthesize playbackStartTime   = _playbackStartTime;
@synthesize frameWasRender      = _frameWasRender;

@synthesize playbackMode        = _playbackMode;

#pragma mark - Init


-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        self.preProcessor = preProcessor;
        self.timeline = timeline;

        self.playbackMode = VSPlaybackModeStanding;
        
        [self initObservers];
    }
    
    return self;
}

- (void)initObservers {
    [self.timeline.playHead addObserver:self forKeyPath:@"scrubbing" options:0 context:nil];
    [self.timeline.playHead addObserver:self forKeyPath:@"jumping" options:0 context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"jumping"]){
        if([[object valueForKey:keyPath] boolValue]){
            
            self.playbackMode = VSPlaybackModeJumping;
            
            self.currentTimestamp = [[object valueForKey:@"currentTimePosition"] doubleValue];
            
            
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
    }
    
    else if([keyPath isEqualToString:@"scrubbing"]){
        BOOL scrubbing = [[object valueForKey:keyPath] boolValue];
        
        self.currentTimestamp = [[object valueForKey:@"currentTimePosition"] doubleValue];
        
        if(scrubbing){
            self.playbackMode = VSPlaybackModeScrubbing;
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
        else{
            self.playbackMode = VSPlaybackModeStanding;
            if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
                [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
            }
            [self stop];
        }
    }
    
}

#pragma mark - Methods

- (void)startPlaybackFromCurrentTimeStamp
{
    NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimer) object:nil]; //Create a new thread
    [timerThread start];
}

-(void) didFinisheRenderingTexture:(GLuint)theTexture forTimestamp:(double)theTimestamp{
    
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate) ]){
            if([self.delegate respondsToSelector:@selector(texture:isReadyForTimestamp:)]){
                [self.delegate texture:theTexture isReadyForTimestamp:theTimestamp];
            }
        }
    }
    
    if(self.playbackMode == VSPlaybackModeJumping){
        if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
            [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
        }
        self.playbackMode = VSPlaybackModeStanding;
    }
}

- (void)renderFramesForCurrentTimestamp{
    if(self.playbackMode == VSPlaybackModePlaying){
        [self computeNewCurrentTimestamp];
    }
    
    [self renderCurrentFrame];
}

-(void) play{
    self.playbackMode = VSPlaybackModePlaying;
    self.playbackStartTime = [[NSDate date] timeIntervalSince1970]*1000;
}

-(void) stop{
    self.playbackMode = VSPlaybackModeStanding;
    [self.preProcessor stopPlayback];
}


#pragma mark - Private Methods

/**
 * Sets the current VSPlaybackMode and tells the preprocessor to the render the current frame
 */
-(void) renderCurrentFrame{
    if (self.preProcessor) {
        
        
        [self.preProcessor processFrameAtTimestamp:self.timeline.playHead.currentTimePosition withFrameSize:[VSProjectSettings sharedProjectSettings].frameSize withPlayMode:self.playbackMode];
    }
    
    //if the render of the was started because the playhead was moved by clicking somewhere on the timeline, the rendering is turned off after the frame was rendered
    if(self.playbackMode == VSPlaybackModeJumping){
        if([self delegateRespondsToSelector:@selector(didStopScrubbingAtTimestamp:)]){
            [self.delegate didStopScrubbingAtTimestamp:self.currentTimestamp];
        }
        self.playbackMode = VSPlaybackModeStanding;
    }
}

/**
 * Computs the current timestamp while playing
 */
-(void) computeNewCurrentTimestamp{
    double currentTime = [[NSDate date] timeIntervalSince1970]*1000;        
    
    self.currentTimestamp += currentTime - self.playbackStartTime;
    
    if(self.currentTimestamp > self.timeline.duration){
        self.currentTimestamp = 0;
    }
    
    self.timeline.playHead.currentTimePosition = self.currentTimestamp;
    self.playbackStartTime = currentTime;
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
