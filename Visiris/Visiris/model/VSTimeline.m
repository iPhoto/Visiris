//
//  VSTimeline.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimeline.h"

#import "VSTrack.h"
#import "VSTimelineObjectFactory.h"
#import "VSProjectItemBrowserViewController.h"
#import "VSProjectItemController.h"
#import "VSProjectItemRepresentation.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectProxy.h"

#import "VSCoreServices.h"

@interface VSTimeline()

/** Reference of the Singleton of the timeline object factory. The Factory creates new TimelineObject according to the information stored in their corresponding ProjectItems */
@property VSTimelineObjectFactory* timelineObjectFactory;

/** Reference of the Singleton of VSProjectItemController. Used to get the ProjectItem corresponding to its VSProjectItem representation */
@property VSProjectItemController *projectItemController;
@end

@implementation VSTimeline

@synthesize tracks = _tracks;
@synthesize timelineObjectFactory = _timelineObjectFactory;
@synthesize projectItemController = _projectItemController;
@synthesize duration = _duration;

#pragma mark- Init

-(id) initWithDuration:(float) duration{
    if(self = [self init]){
        self.duration = duration;
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        self.timelineObjectFactory = [VSTimelineObjectFactory sharedManager];
        self.projectItemController = [VSProjectItemController sharedManager];
        self.tracks = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

#pragma mark- Methods

-(BOOL) addNewTrackNamed:(NSString *)name ofType:(VSTrackType)type{
    [self.tracks addObject:[[VSTrack alloc] initWithName:name type:type]];
    
    return YES;
}

-(VSTimelineObject*) addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *) item toTrack :(VSTrack *)track positionedAtTime:(double) timePosition withDuration:(double)duration{
    
    // Fetches the projectItem corresponding to the given representation */
    VSProjectItem *newItem = [self.projectItemController projectItemWithID:item.itemID];
    
    if(!newItem)
        return nil;
    
    // Tells the factory to create a new TimelineObject according to the given VSProjectItemRepresentation */
    VSTimelineObject *newObject = [self.timelineObjectFactory createTimelineObjectForProjectItem:newItem];
    
    if(!newObject)
        return nil;
    
    newObject.startTime = timePosition;
    newObject.duration = duration;
    
    // If the endposition of the new TimelineObject is greater than the duration of the timeline, the timeline's duration is enlarged */
    if(newObject.endTime > self.duration)
        self.duration = newObject.endTime;
    
    // Adds the new object to the given track */
    [track addTimelineObject:newObject];
    
    return newObject;
}

-(VSTimelineObjectProxy*) createNewTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item positionedAtTime:(double)timePosition{
    
    NSImage* icon = [VSFileImageCreator createIconForTimelineObject:item.filePath];
    
    VSTimelineObjectProxy *newProxy = [[VSTimelineObjectProxy alloc] initWithName:item.name atTime:timePosition  duration:item.duration icon:icon];
    
    return newProxy;
    
}


-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject fromTrack:(VSTrack *)track{
    return [track removTimelineObject:aTimelineObject];
}

-(void) selectTimelineObject:(VSTimelineObject *)timelineObjectToSelect onTrack:(VSTrack *)aTrack{
    if([self.tracks containsObject:aTrack]){
        [aTrack selecteTimelineObject:timelineObjectToSelect];
    }
}

-(void) unselectTimelineObject:(VSTimelineObject *)timelineObjectToUnselect onTrack:(VSTrack *)aTrack{
    if([self.tracks containsObject:aTrack]){
        [aTrack selecteTimelineObject:timelineObjectToUnselect];
    }
}

-(void) unselectAllTimelineObjects{
    for (VSTrack *track in self.tracks){
        [track unselectAllTimelineObjects];
    }
}

-(NSArray*) selectedTimelineObjects{
    NSMutableArray *selectdTimelineObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for (VSTrack *track in self.tracks){
        [selectdTimelineObjects addObjectsFromArray:[track selectedTimelineObjects]];
    }
    
    return selectdTimelineObjects;
}

#pragma mark - AccessTimeLineObjects

//TODO: read out the objects
- (NSArray *)timelineObjectsForTimestamp:(double)aTimestamp
{
    NSMutableArray *currentActiveTimeLineObjects = [[NSMutableArray alloc] init ];
    
    for(VSTrack *track in self.tracks){
        [currentActiveTimeLineObjects addObjectsFromArray:track.timelineObjects];
    }
    
    return currentActiveTimeLineObjects;
}

@end
