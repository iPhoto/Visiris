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

- (void)processFrameAtTimestamp:(double)aTimestamp withFrameSize:(NSSize)aFrameSize isPlaying:(BOOL)playing
{
    NSArray *currentTimeLineObjects = [self.timeline timelineObjectsForTimestamp:aTimestamp];
    
    NSMutableArray *handoverObjects = [[NSMutableArray alloc] init];
    
    for (VSTimelineObject *currentTimeLineObject in currentTimeLineObjects) {
        VSCoreHandover *coreHandover = [currentTimeLineObject handoverForTimestamp:aTimestamp frameSize:aFrameSize isPlaying:playing];
        if (coreHandover) {
            [handoverObjects addObject:coreHandover];
        }
    }
    
    [self.renderCoreReceptionist renderFrameAtTimestamp:aTimestamp withHandovers:handoverObjects forSize:aFrameSize];
}

#pragma mark - VSTimelineTimelineObjectsDelegate implementation

-(void) timelineObjectsWillBeRemoved:(NSArray *)removedTimelineObjects{
    DDLogInfo(@"%@",removedTimelineObjects);
    
    for (VSTimelineObject *timelineObject in removedTimelineObjects){
        [self.renderCoreReceptionist removeTextureForID:timelineObject.textureID];
    }
}

//TODO: add colorspace
-(void) timelineObjects:(NSArray *)newTimelineObjects haveBeenAddedToTrack:(VSTrack *)aTrack{
    //DDLogInfo(@"%@",newTimelineObjects);
    
    for(VSTimelineObject *timelineObject in newTimelineObjects){
        
        NSSize dimensions = [VSFileUtils dimensionsOfFile:timelineObject.sourceObject.filePath];
        VSFileType *type = [VSSupportedFilesManager typeOFile:timelineObject.sourceObject.filePath];
       
        NSLog(@"[VSProjectSettings sharedProjectSettings].frameSize still missing");
        //NSSize outputSize = [VSProjectSettings sharedProjectSettings].frameSize;
        NSSize outputSize = NSMakeSize(800, 600);
                        
        timelineObject.textureID = [self.renderCoreReceptionist createNewTextureForSize:dimensions 
                                                                              colorMode:nil 
                                                                               forTrack:aTrack.trackID 
                                                                               withType:type.fileKind 
                                                                         withOutputSize:outputSize
                                                                               withPath:timelineObject.sourceObject.filePath];
    }
}

@end
