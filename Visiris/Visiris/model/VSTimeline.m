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
#import "VSPlayHead.h"
#import "VSTimelineObjectSource.h"

#import "VSCoreServices.h"






@interface VSTimeline()

/** Reference of the Singleton of the timeline object factory. The Factory creates new TimelineObject according to the information stored in their corresponding ProjectItems */
@property VSTimelineObjectFactory* timelineObjectFactory;

/** Reference of the Singleton of VSProjectItemController. Used to get the ProjectItem corresponding to its VSProjectItem representation */
@property VSProjectItemController *projectItemController;

/** Stores the last assigned track id*/
@property NSInteger lastTrackID;

@end






@implementation VSTimeline

@synthesize tracks                  = _tracks;
@synthesize timelineObjectFactory   = _timelineObjectFactory;
@synthesize projectItemController   = _projectItemController;
@synthesize duration                = _duration;
@synthesize timelineObjectsDelegate = _timelineObjectsDelegate;
@synthesize playHead                = _playHead;
@synthesize lastTrackID             = _lastTrackID;

#pragma mark- Init

-(id) initWithDuration:(float) duration{
    if(self = [self init]){
        self.duration = duration;
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        self.timelineObjectFactory = [VSTimelineObjectFactory sharedFactory];
        self.projectItemController = [VSProjectItemController sharedManager];
        self.tracks = [[NSMutableArray alloc] init];
        
        [self initPlayHead];
    }
    
    return self;
}

/**
 * Inits the VSPlayHead-property*/
-(void) initPlayHead{
    self.playHead = [[VSPlayHead alloc] init];
}


#pragma mark - NSObject

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([object isKindOfClass:[VSTrack class]]){
        
        VSTrack *affectedTrack = (VSTrack*) object;
        
        if([keyPath isEqualToString:@"timelineObjects"]){
            
            NSInteger kind = [[change valueForKey:@"kind"] intValue];
            
            switch (kind) {
                case NSKeyValueChangeInsertion:
                {
                    if(![[change valueForKey:@"notificationIsPrior"] boolValue]){ 
                        NSArray *allTimelineObjects = [affectedTrack valueForKey:keyPath];
                        NSArray *newTimelineObjects = [allTimelineObjects objectsAtIndexes:[change  objectForKey:@"indexes"]];
                        
                        if([self timelineObjectsDelegateImplementsSelector:@selector(timelineObjects:haveBeenAddedToTrack:)]){
                            [self.timelineObjectsDelegate timelineObjects:newTimelineObjects haveBeenAddedToTrack:affectedTrack];
                        }
                    }
                    break;
                }
                case NSKeyValueChangeRemoval:
                {
                    if([[change valueForKey:@"notificationIsPrior"] boolValue]){ 
                        NSArray *allTimelineObjects = [affectedTrack valueForKey:keyPath];
                        NSArray *removedTimelineObjects = [allTimelineObjects objectsAtIndexes:[change  objectForKey:@"indexes"]];
                        
                        if([self timelineObjectsDelegateImplementsSelector:@selector(timelineObjectsWillBeRemoved:)]){
                            [self.timelineObjectsDelegate timelineObjectsWillBeRemoved:removedTimelineObjects];
                        }
                        
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
}

#pragma mark - Methods

#pragma mark Tracks

-(BOOL) addNewTrackNamed:(NSString *)name ofType:(VSTrackType)type{
    VSTrack* newTrack = [[VSTrack alloc] initWithName:name trackID:[self nextAvailableTrackID] type:type];
    
    [newTrack addObserver:self forKeyPath:@"timelineObjects" options:NSKeyValueObservingOptionPrior |NSKeyValueObservingOptionNew context:nil];
    
    [self.tracks addObject:newTrack];
    return YES;
}

#pragma mark Add TimelineObjects

-(VSTimelineObject*) addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item toTrack:(VSTrack *)track positionedAtTime:(double)timePosition withDuration:(double)duration{
    
    VSTimelineObject* newTimelineObject = [self createTimelineObjectBasedOnProjectItemRepresentation:item positionedAtTime:timePosition withDuration:duration];
    
    // Adds the new object to the given track */
    [track addTimelineObject:newTimelineObject];
    
    return newTimelineObject;
}

-(VSTimelineObject*) addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item toTrack:(VSTrack *)track positionedAtTime:(double)timePosition withDuration:(double)duration andRegisterUndoOperation:(NSUndoManager *)undoManager{
    
    VSTimelineObject* newTimelineObject = [self createTimelineObjectBasedOnProjectItemRepresentation:item positionedAtTime:timePosition withDuration:duration];
    
    // Adds the new object to the given track */
    [track addTimelineObject:newTimelineObject andRegisterAtUndoManager:undoManager];
    
    return newTimelineObject;
}

-(VSTimelineObjectProxy*) createNewTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item positionedAtTime:(double)timePosition{
    
    NSImage* icon = [VSFileImageCreator createIconForTimelineObject:item.filePath];
    
    VSTimelineObjectProxy *newProxy = [[VSTimelineObjectProxy alloc] initWithName:item.name atTime:timePosition  duration:item.duration icon:icon];
    
    return newProxy;
    
}

#pragma mark Copy TimlineObjects

-(VSTimelineObject*) copyTimelineObject:(VSTimelineObject *)baseTimelineObject toTrack:(VSTrack *)track atPosition:(double)position withDuration:(double)duration{
    
    
   return [self addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation*) baseTimelineObject.sourceObject.projectItem toTrack:track positionedAtTime:position withDuration:duration];
}

-(VSTimelineObject*) copyTimelineObject:(VSTimelineObject *)baseTimelineObject toTrack:(VSTrack *)track atPosition:(double)position withDuration:(double)duration andRegisterUndoOperation:(NSUndoManager *)undoManager{

    return [self addNewTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation*) baseTimelineObject.sourceObject.projectItem toTrack:track positionedAtTime:position withDuration:duration andRegisterUndoOperation:undoManager];
}

#pragma mark Remove TimelineObjects

-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject fromTrack:(VSTrack *)track{
    return [track removTimelineObject:aTimelineObject];
}

-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject fromTrack:(VSTrack *)track andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    return [track removTimelineObject:aTimelineObject andRegisterAtUndoManager:undoManager];
}

#pragma mark TimelineObject-Selection

-(void) removeSelectedTimelineObjectsAndRegisterAtUndoManager:(NSUndoManager *)undoManager{
    for(VSTrack* track in self.tracks){
        [track removeSelectedTimelineObjectsAndRegisterAtUndoManager:undoManager];
    }
}

-(void) selectTimelineObject:(VSTimelineObject *)timelineObjectToSelect onTrack:(VSTrack *)aTrack{
    if([self.tracks containsObject:aTrack]){
        [aTrack selectTimelineObject:timelineObjectToSelect];
    }
}

-(void) unselectTimelineObject:(VSTimelineObject *)timelineObjectToUnselect onTrack:(VSTrack *)aTrack{
    if([self.tracks containsObject:aTrack]){
        [aTrack selectTimelineObject:timelineObjectToUnselect];
    }
}

-(void) unselectAllTimelineObjects{
    if(self.tracks.count == 0)
        return;
    for (VSTrack *track in self.tracks){
        if(track){
            [track unselectAllTimelineObjects];
        }
    }
}

-(NSArray*) selectedTimelineObjects{
    NSMutableArray *selectdTimelineObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for (VSTrack *track in self.tracks){
        [selectdTimelineObjects addObjectsFromArray:[track selectedTimelineObjects]];
    }
    
    return selectdTimelineObjects;
}

#pragma mark AccessTimeLineObjects

- (NSArray *)timelineObjectsForTimestamp:(double)aTimestamp
{
    NSMutableArray *currentActiveTimeLineObjects = [[NSMutableArray alloc] init ];
    
    //iteratres through the timeline's tracks and adds the VSTimlineObject active at this timestamp to the currentActiveTimeLineObjects-Array
    for(VSTrack *track in self.tracks){
        VSTimelineObject *currentObject = [track timelineObjectAtTimestamp:aTimestamp];
        if(currentObject){
            [currentActiveTimeLineObjects addObject:currentObject];
        }
    }
    
    return currentActiveTimeLineObjects;
}


#pragma mark - Private Methods

/**
 * Creates a new VSTimelineObject.
 *
 * A new timeline object is created by the VSTimelineObjectFactory according to the given VSProjectItem.
 * @param item VSTimelineObjectRepresentation the new TimelineObject is connected with
 * @param timePosition Start-time of the timelineObject.
 * @param duration Duration of the VSTimelineObject
 * @return The newly create VSTimelineObject if the creation was successfully, nil otherwise.
 */
-(VSTimelineObject*) createTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *) item positionedAtTime:(double) timePosition withDuration:(double) duration{
    
    
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
    
    return newObject;
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) timelineObjectsDelegateImplementsSelector:(SEL) selector{
    if(self.timelineObjectsDelegate){
        if([self.timelineObjectsDelegate conformsToProtocol:@protocol(VSTimelineTimelineObjectsDelegate) ]){
            if([self.timelineObjectsDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

/**
 * Increments the lastAssignedTrackID and returns it.
 * @return A new unique track id
 */
-(NSInteger) nextAvailableTrackID{
    return ++self.lastTrackID;
}

@end
