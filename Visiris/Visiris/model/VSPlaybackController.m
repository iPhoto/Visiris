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
#import "VSDocument.h"

@interface VSPlaybackController()

/** Times the playback */
@property NSTimer *playbackTimer;

/** Timestamp when the playback was started */
@property double playbackStartTime;

@property VSPreProcessor* preProcessor;

@property VSTimeline* timeline;

@property (strong) VSTimelineObject*selectedTimelineObject;
//todo
@property (assign) double deltaTime;

//todo
@property (assign) double counter;

@property (weak) VSOutputController *outputController;

@property (weak) VSDocument *document;

@end

@implementation VSPlaybackController


#pragma mark - Init

-(id) initWithPreProcessor:(VSPreProcessor *)preProcessor andOutputController:(VSOutputController*) outputController forTimeline:(VSTimeline *)timeline ofDocument:(VSDocument*) document{
    if(self = [super init]){
        self.preProcessor = preProcessor;
        self.timeline = timeline;
        
        self.playbackMode = VSPlaybackModeNone;
        
        [self initObservers];
        
        self.counter = 0.0;
        self.deltaTime = 0.0;
        self.document = document;
        self.outputController = outputController;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playKeyWasPressed:)
                                                 name:VSPlayKeyWasPressed
                                               object:nil];
}

/**
 * Called when the VSPlayKeyWasPressed notification was received.
 *
 * Stops the the playback if the playMode of the playbackController is VSPlaybackModePlaying and starts it otherwise
 *
 * @param theNotification NSNotification send from the notification
 */
-(void) playKeyWasPressed:(NSNotification*) theNotification{
    if ([[theNotification.userInfo objectForKey:VSSendersDocumentKeyInUserInfoDictionary] isEqualTo:self.document]){
        if(self.playbackMode != VSPlaybackModePlaying){
            [self play];
        }
        else {
            [self stop];
        }
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"jumping"]){
        if([[object valueForKey:keyPath] boolValue]){
            
            self.playbackMode = VSPlaybackModeJumping;
            
            self.currentTimestamp = [[object valueForKey:@"currentTimePosition"] doubleValue];
            
            
            [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
            
        }
    }
    
    else if([keyPath isEqualToString:@"scrubbing"]){
        BOOL scrubbing = [[object valueForKey:keyPath] boolValue];
        
        self.currentTimestamp = [[object valueForKey:@"currentTimePosition"] doubleValue];
        
        if(scrubbing){
            self.playbackMode = VSPlaybackModeScrubbing;
            [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
            
        }
        else{
            self.playbackMode = VSPlaybackModeNone;
            [self.outputController didStopScrubbingAtTimestamp:self.currentTimestamp];
            
            [self stop];
        }
    }
    else if([keyPath isEqualToString:@"currentValue"]){
        if(self.playbackMode == VSPlaybackModeNone){
            self.playbackMode = VSPlaybackModeJumping;
            
            [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
            
        }
    }
    else if([keyPath isEqualToString:@"duration"]){
        if(self.playbackMode == VSPlaybackModeNone){
            self.playbackMode = VSPlaybackModeJumping;
            
            [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
            
        }
    }
    else if([keyPath isEqualToString:@"startTime"]){
        if(self.playbackMode == VSPlaybackModeNone){
            self.playbackMode = VSPlaybackModeJumping;
            
            [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
            
        }
    }
    
    
}

#pragma mark - Methods

-(void) didFinisheRenderingTexture:(GLuint)theTexture forTimestamp:(double)theTimestamp{
    
    
    [self.outputController texture:theTexture isReadyForTimestamp:theTimestamp];
    
    
    
    if(self.playbackMode == VSPlaybackModeJumping){
        [self.outputController didStopScrubbingAtTimestamp:self.currentTimestamp];
        self.playbackMode = VSPlaybackModeNone;
    }
}

- (void)renderFramesForCurrentTimestamp:(NSSize)size{
    switch (self.playbackMode) {
        case VSPlaybackModePlaying:
            [self computeNewCurrentTimestamp];
            
            self.counter += self.deltaTime/1000.0;
            
            //todo is this slow?
            double period = 1.0 / [VSProjectSettings sharedProjectSettings].frameRate;
            
            if (self.counter >= period) {
                self.counter -= period;
                
                [self renderCurrentFrame:size];
            }
            break;
        case VSPlaybackModeJumping:
        case VSPlaybackModeScrubbing:
            [self renderCurrentFrame:size];
            self.counter = 0.0;
            break;
        default:
            DDLogInfo(@"VSPlabackMode is none");
            break;
    }
}

-(void) updateCurrentFrame{
    if(self.playbackMode == VSPlaybackModeNone){
        self.playbackMode = VSPlaybackModeJumping;
        
        
        [self.outputController didStartScrubbingAtTimestamp:self.currentTimestamp];
        
    }
}

-(void) play{
    
    [self.outputController startPlayback];
    self.playbackStartTime = CFAbsoluteTimeGetCurrent();
    
    self.currentTimestamp = self.timeline.playHead.currentTimePosition;
    
    self.playbackMode = VSPlaybackModePlaying;
}

-(void) stop{
    self.playbackMode = VSPlaybackModeNone;
    [self.preProcessor stopPlayback];
    [self.outputController stopPlayback];
}


#pragma mark - VSPreProcessorDelegate Implementation

-(void) removedTimelineObjectsfromRenderCore:(NSArray *)timelineObjects{
    [self updateCurrentFrame];
}

-(void) addedTimelineObjectsToRenderCore:(NSArray *)timelineObjects{
    [self updateCurrentFrame];
}

#pragma mark - Private Methods

/**
 * Called when a VSTimelineObjectsGotUnselected-Notification was received.
 *
 * Removes the obserserves for the currentValues of the unselected VSTimelineObject's parameters
 * @param notification NSNotification storing the unselected VSTimelineObject
 */
-(void) timelineObjectsGotUnselected:(NSNotification *) notification{
    if ([[notification.userInfo objectForKey:VSSendersDocumentKeyInUserInfoDictionary] isEqualTo:self.document]){
        if([[notification object] isKindOfClass:[NSArray class]]){
            NSArray *unselectedTimelineObjects = notification.object;
            
            
            for(VSTimelineObject *unselectedTimelineObject in unselectedTimelineObjects){
                [self removeObserversFromSelecteTimelineObject];
            }
        }
        
        self.selectedTimelineObject = nil;
    }
    
}

-(void) removeObserversFromSelecteTimelineObject{
    for(VSParameter *parameter in [self.selectedTimelineObject visibleParameters]){
        [parameter removeObserver:self forKeyPath:@"currentValue"];
    }
    
    [self.selectedTimelineObject removeObserver:self
                                     forKeyPath:@"startTime"];
    
    [self.selectedTimelineObject removeObserver:self
                                     forKeyPath:@"duration"];
}

/**
 * Called when a VSTimelineObjectsGotSelected-Notification was received.
 *
 * Adds obserserves for the currentValues of the selected VSTimelineObject's parameters
 * @param notification NSNotification storing the selected VSTimelineObject
 */
-(void) timelineObjectsGotSelected:(NSNotification *) notification{
    if ([[notification.userInfo objectForKey:VSSendersDocumentKeyInUserInfoDictionary] isEqualTo:self.document]){
        if(self.selectedTimelineObject){
            [self removeObserversFromSelecteTimelineObject];
        }
        
        if([[notification object] isKindOfClass:[NSArray class]]){
            
            NSArray *selectedTimelineObjects = notification.object;
            
            VSTimelineObject *selectedTimelineObject = [selectedTimelineObjects objectAtIndex:0];
            if([selectedTimelineObject isKindOfClass:[VSTimelineObject class]]){
                
                self.selectedTimelineObject = selectedTimelineObject;
                
                [self.selectedTimelineObject addObserver:self
                                              forKeyPath:@"startTime"
                                                 options:0
                                                 context:nil];
                
                [self.selectedTimelineObject addObserver:self
                                              forKeyPath:@"duration"
                                                 options:0
                                                 context:nil];
                
                for(VSParameter *parameter in [self.selectedTimelineObject visibleParameters]){
                    [parameter addObserver:self
                                forKeyPath:@"currentValue"
                                   options:0
                                   context:nil];
                }
            }
        }
    }
    
}

/**
 * Sets the current VSPlaybackMode and tells the preprocessor to the render the current frame
 */
- (void)renderCurrentFrame:(NSSize)size{
    
    if (self.preProcessor) {
        [self.preProcessor processFrameAtTimestamp:self.timeline.playHead.currentTimePosition withFrameSize:size withPlayMode:self.playbackMode];
    }
    
    //if the render of the was started because the playhead was moved by clicking somewhere on the timeline, the rendering is turned off after the frame was rendered
    if(self.playbackMode == VSPlaybackModeJumping){
        [self.outputController didStopScrubbingAtTimestamp:self.currentTimestamp];
        self.playbackMode = VSPlaybackModeNone;
    }
}

/**
 * Computs the current timestamp while playing
 */
- (void)computeNewCurrentTimestamp{
    
    double currentTime;
    
    
    currentTime = CFAbsoluteTimeGetCurrent();
    
    self.deltaTime = (currentTime - self.playbackStartTime)*1000.0;
    self.currentTimestamp += self.deltaTime;
    
    if(self.currentTimestamp > self.timeline.duration){
        self.currentTimestamp = 0;
    }
    self.timeline.playHead.currentTimePosition = self.currentTimestamp;
    self.playbackStartTime = currentTime;
}

@end
