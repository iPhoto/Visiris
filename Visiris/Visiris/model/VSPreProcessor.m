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

@interface VSPreProcessor()
@end


@implementation VSPreProcessor

@synthesize timeline = _timeline;
@synthesize renderCoreReceptionist=_renderCoreReceptionist;


#pragma mark - Init

-(id)initWithTimeline:(VSTimeline *)timeline{
    if(self = [super init]){
        self.timeline = timeline;
        self.renderCoreReceptionist = [[VSCoreReceptionist alloc] init];
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
    //DDLogInfo(@"%@",removedTimelineObjects);
    
    for (VSTimelineObject *timelineObject in removedTimelineObjects){
        [self.renderCoreReceptionist removeTextureForID:timelineObject.textureID];
    }
}

//TODO: add colorspace...but i think we don't need it
-(void) timelineObjects:(NSArray *)newTimelineObjects haveBeenAddedToTrack:(VSTrack *)aTrack{
    //DDLogInfo(@"%@",newTimelineObjects);
    
    for(VSTimelineObject *timelineObject in newTimelineObjects){
        
        switch (timelineObject.sourceObject.projectItem.fileType.fileKind) {
            case VSFileKindAudio:
            {
                [self handleAudioTimelineObject:timelineObject atTrack:aTrack];
            }
            break;
                
            case VSFileKindImage:
            case VSFileKindVideo:
            case VSFileKindQuartzComposerPatch:
            {
                [self handleFrameTimelineObject:timelineObject atTrack:aTrack];
            }
            break;

                default:
                break;
        }
    }
}

#pragma mark - Private Methods

- (void)handleFrameTimelineObject:(VSTimelineObject *)timelineObject atTrack:(VSTrack *)track{
    
    NSSize dimensions = [VSFileUtils dimensionsOfFile:timelineObject.sourceObject.filePath];
    VSFileType *type = [VSSupportedFilesManager typeOFile:timelineObject.sourceObject.filePath];
    
    NSSize outputSize = [VSProjectSettings sharedProjectSettings].frameSize;
    
    timelineObject.textureID = [self.renderCoreReceptionist createNewTextureForSize:dimensions 
                                                                          colorMode:nil 
                                                                           forTrack:track.trackID 
                                                                           withType:type.fileKind 
                                                                     withOutputSize:outputSize
                                                                           withPath:timelineObject.sourceObject.filePath];

}

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
