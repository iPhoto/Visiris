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
#import "VSTimelineObject.h"
#import "VSParameter.h"

@interface VSPlaybackController()

/** Times the playback */
@property NSTimer *playbackTimer;

/** Timestamp when the playback was started */
@property double playbackStartTime;

@property VSPreProcessor* preProcessor;

@property VSTimeline* timeline;

@property VSTimelineObject *selectedTimelineObject;
//todo
@property (assign) double deltaTime;

//todo
@property (assign) double counter;
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
@synthesize deltaTime           = _deltaTime;
@synthesize counter             = _counter;

#pragma mark - Init


-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor timeline:(VSTimeline *)timeline{
    if(self = [super init]){
        self.preProcessor = preProcessor;
        self.timeline = timeline;
        
        self.playbackMode = VSPlaybackModeStanding;
        
        [self initObservers];
        
        self.counter = 0.0;
        self.deltaTime = 0.0;
    }
    
    return self;
}

- (void)initObservers {
    [self.timeline.playHead addObserver:self
                             forKeyPath:@"scrubbing"
                                options:0
                                context:nil];
    
    [self.timeline.playHead addObserver:self
                             forKeyPath:@"jumping"
                                options:0
                                context:nil];
    
    //Adding Observer for TimelineObjects got selected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineObjectsGotSelected:)
                                                 name:VSTimelineObjectsGotSelected
                                               object:nil];
    
    //Adding Observer for TimelineObjects got unselected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineObjectsGotUnselected:)
                                                 name:VSTimelineObjectsGotUnselected
                                               object:nil];
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
    else if([keyPath isEqualToString:@"currentValue"]){
        if(self.playbackMode == VSPlaybackModeStanding){
            self.playbackMode = VSPlaybackModeJumping;
            if([self delegateRespondsToSelector:@selector(didStartScrubbingAtTimestamp:)]){
                [self.delegate didStartScrubbingAtTimestamp:self.currentTimestamp];
            }
        }
    }
    
}

#pragma mark - Methods

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
    switch (self.playbackMode) {
        case VSPlaybackModePlaying:
            [self computeNewCurrentTimestamp];
            
            self.counter += self.deltaTime/1000.0;
            
            //todo is this slow?
            double period = 1.0 / [VSProjectSettings sharedProjectSettings].frameRate;
            
            if (self.counter >= period) {
                self.counter -= period;
                
                [self renderCurrentFrame];
            }
            break;
        case VSPlaybackModeJumping:
        case VSPlaybackModeScrubbing:
            [self renderCurrentFrame];
            self.counter = 0.0;
            break;
        default:
            NSLog(@"ERROR in RENDERFRAMESFORCURRENTTIMESTAMP");
            break;
    }
}

-(void) play{
    self.playbackMode = VSPlaybackModePlaying;
    
    if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate)]){
        self.playbackStartTime = [self.delegate hostTime];
    }
}

-(void) stop{
    self.playbackMode = VSPlaybackModeStanding;
    [self.preProcessor stopPlayback];
}


#pragma mark - Private Methods

-(void) timelineObjectsGotUnselected:(NSNotification *) notification{
    for(VSParameter *parameter in [self.selectedTimelineObject.parameters allValues]){
        [parameter removeObserver:self forKeyPath:@"currentValue"];
    }
    
    self.selectedTimelineObject = nil;
}

-(void) timelineObjectsGotSelected:(NSNotification *) notification{
    if([[notification object] isKindOfClass:[NSArray class]]){
        NSArray *selectedTimelineObjects = (NSArray*) [notification object];
        
        if(selectedTimelineObjects && selectedTimelineObjects.count > 0){
            if([[selectedTimelineObjects objectAtIndex:0] isKindOfClass:[VSTimelineObject class]]){
                
                self.selectedTimelineObject = (VSTimelineObject*) [selectedTimelineObjects objectAtIndex:0];
                
                for(VSParameter *parameter in [self.selectedTimelineObject.parameters allValues]){
                    [parameter addObserver:self forKeyPath:@"currentValue" options:0 context:nil];
                }
            }
        }
    }
}

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
- (void)computeNewCurrentTimestamp{

    double currentTime;
    
    if([self.delegate conformsToProtocol:@protocol(VSPlaybackControllerDelegate)]){
        currentTime = [self.delegate hostTime];
    }
    else
        NSLog(@"ERROR: delegate not responding");

    self.deltaTime = (currentTime - self.playbackStartTime)/1000000.0;
    self.currentTimestamp += self.deltaTime;
        
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
