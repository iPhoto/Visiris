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

- (void)processFrameAtTimestamp:(double)aTimestamp withFrameSize:(NSSize)aFrameSize
{
    NSArray *currentTimeLineObjects = [self.timeline timelineObjectsForTimestamp:aTimestamp];
    
    NSMutableArray *handoverObjects = [[NSMutableArray alloc] init];
    
    for (VSTimelineObject *currentTimeLineObject in currentTimeLineObjects) {
        VSCoreHandover *coreHandover = [currentTimeLineObject handoverForTimestamp:aTimestamp frameSize:aFrameSize];
        if (coreHandover) {
            [handoverObjects addObject:coreHandover];
        }
    }
    
    if (self.renderCoreReceptionist && handoverObjects) {
        DDLogInfo(@"out");
        [self.renderCoreReceptionist renderFrameAtTimestamp:aTimestamp withHandovers:handoverObjects forSize:aFrameSize];
    }
}

#pragma mark - VSTimelineTimelineObjectsDelegate implementation

-(void) timelineObjects:(NSArray *)removedTimelineObjects willBeRemovedFromTrack:(VSTrack *)aTrack{
    DDLogInfo(@"%@",removedTimelineObjects);
    
    for (VSTimelineObject *timelineObject in removedTimelineObjects){
        [self.renderCoreReceptionist removeTextureForID:timelineObject.textureID];
    }
}

//TODO: add colorspace
-(void) timelineObjects:(NSArray *)newTimelineObjects haveBeenAddedToTrack:(VSTrack *)aTrack{
    DDLogInfo(@"%@",newTimelineObjects);
    
    for(VSTimelineObject *timelineObject in newTimelineObjects){
        NSSize dimensions = [VSFileUtils dimensionsOfFile:timelineObject.sourceObject.filePath];

        timelineObject.textureID = [self.renderCoreReceptionist createNewTextureForSize:dimensions colorMode:nil];
    }
}

@end
