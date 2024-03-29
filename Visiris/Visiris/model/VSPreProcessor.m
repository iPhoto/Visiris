//
//  VSPreProcessor.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPreProcessor.h"

#import "VSTimeline.h"
#import "VisirisCore/VSCoreReceptionist.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"
#import "VSSourceSupplier.h"
#import "VSProjectSettings.h"
#import "VSFileType.h"
#import "VSQuartzCompositionUtils.h"
#import "VSProjectItem.h"
#import "VSOutputController.h"
#import "VSPlaybackController.h"

#import "VSCoreServices.h"

@interface VSPreProcessor()

@property NSMutableArray *timelineObjectsToRemove;

@property (assign) NSUInteger amountOfLastSentHandovers;

@end


@implementation VSPreProcessor


#pragma mark - Init

-(id)initWithTimeline:(VSTimeline *)timeline andCoreReceptionist:(VSCoreReceptionist*) coreReceptionist{
    if(self = [super init]){
        self.timeline = timeline;
        self.amountOfLastSentHandovers = 0;
        self.renderCoreReceptionist = coreReceptionist;
    }
    return self;
}


#pragma mark - Methods

- (void)processFrameAtTimestamp:(double)aTimestamp withFrameSize:(NSSize)aFrameSize withPlayMode:(VSPlaybackMode)playMode
{
    NSArray *currentTimeLineObjects = [self.timeline timelineObjectsForTimestamp:aTimestamp];
    
    NSMutableArray *handoverObjects = [[NSMutableArray alloc] init];
    
    for (VSTimelineObject *currentTimeLineObject in currentTimeLineObjects) {
        VSCoreHandover *coreHandover = [currentTimeLineObject handoverForTimestamp:aTimestamp frameSize:aFrameSize withPlayMode:playMode];
        if (coreHandover) {
            [handoverObjects addObject:coreHandover];
        }
    }

    [self.renderCoreReceptionist renderFrameAtTimestamp:aTimestamp withHandovers:handoverObjects forSize:aFrameSize withPlayMode:playMode];
}

#pragma mark - VSTimelineTimelineObjectsDelegate implementation

-(void) timelineObjectsWillBeRemoved:(NSArray *)removedTimelineObjects{
    
    self.timelineObjectsToRemove = [[NSMutableArray alloc] init];
    
    for (VSTimelineObject *timelineObject in removedTimelineObjects){
        [self.timelineObjectsToRemove addObject:[NSNumber numberWithInteger:timelineObject.timelineObjectID]];
    }
    
    if([self delegateRespondsToSelector:@selector(removedTimelineObjectsfromRenderCore:)]){
        [self.delegate removedTimelineObjectsfromRenderCore:removedTimelineObjects];
    }
}

-(void) timelineObjectsHaveBeenRemoved{
    for(id key in self.timelineObjectsToRemove){
        [self.renderCoreReceptionist willRemoveTimelineobjectWithID:[key integerValue]];
    }
}

-(void) timelineObjects:(NSArray *)newTimelineObjects haveBeenAddedToTrack:(VSTrack *)aTrack{
    
    for(VSTimelineObject *timelineObject in newTimelineObjects){
        
        switch (timelineObject.sourceObject.projectItem.fileType.fileKind) {
            case VSFileKindAudio:
                [self handleAudioTimelineObject:timelineObject atTrack:aTrack];
                break;
            case VSFileKindVideo:
                [self handleFrameTimelineObject:timelineObject atTrack:aTrack];
                [self handleAudioTimelineObject:timelineObject atTrack:aTrack];
                break;
            case VSFileKindImage:
            case VSFileKindQuartzComposerPatch:
                [self handleFrameTimelineObject:timelineObject atTrack:aTrack];
                break;
            default:
                break;
        }
    }

    if([self delegateRespondsToSelector:@selector(addedTimelineObjectsToRenderCore:)]){
        [self.delegate addedTimelineObjectsToRenderCore:newTimelineObjects];
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate != nil){
        if([self.delegate conformsToProtocol:@protocol(VSPreProcessorDelegate) ]){
            if([self.delegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)handleFrameTimelineObject:(VSTimelineObject *)timelineObject atTrack:(VSTrack *)track{
    
    NSSize dimensions = [VSFileUtils dimensionsOfFile:timelineObject.sourceObject.filePath];
    VSFileType *type = [VSSupportedFilesManager typeOFile:timelineObject.sourceObject.filePath];
    NSSize outputSize = [VSProjectSettings sharedProjectSettings].frameSize;
    NSInteger objectItemID = timelineObject.timelineObjectID;
    
    [self.renderCoreReceptionist createNewTextureForSize:dimensions
                                               colorMode:nil
                                                forTrack:track.trackID
                                                withType:type.fileKind
                                          withOutputSize:outputSize
                                                withPath:timelineObject.sourceObject.filePath
                                        withObjectItemID:objectItemID];
}

/**
 *
 */
- (void)handleAudioTimelineObject:(VSTimelineObject *)timelineObject atTrack:(VSTrack *)track{
    
    if (timelineObject && track) {
        
        NSInteger projectItemID = timelineObject.sourceObject.projectItem.itemID;
        NSInteger trackID = track.trackID;
        NSString *filePath = timelineObject.sourceObject.filePath;
        NSInteger objectItemID = timelineObject.timelineObjectID;
        
        [self.renderCoreReceptionist createNewAudioPlayerWithProjectItemID:projectItemID withObjectItemID:objectItemID forTrack:trackID andFilePath:filePath];
    }
}

- (void)stopPlayback{
    [self.renderCoreReceptionist stopPlaying];
}

@end
