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



/** Stores the last assigned track id*/
@property NSInteger lastTrackID;

@end






@implementation VSTimeline

@synthesize timelineObjectsDelegate     = _timelineObjectsDelegate;

#pragma mark- Init

#define kDuration @"Duration"
#define kTracks @"Tracks"
#define kTimelineObjectsDelegate @"TimelineObjectsDelegate"
#define kPlayHead @"PlayHead"

-(id) initWithDuration:(float) duration andProjectItemController:(VSProjectItemController *)projectItemController{
    if(self = [self initWithProjectItemController:projectItemController]){
        self.duration = duration;
    }
    
    return self;
}

-(id) initWithProjectItemController:(VSProjectItemController*) projectItemController{
    if(self = [self init]){
        self.timelineObjectFactory = [VSTimelineObjectFactory sharedFactory];
        self.projectItemController = projectItemController;
        self.tracks = [[NSMutableArray alloc] init];
        
        [self initPlayHead];
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        self.timelineObjectFactory = [VSTimelineObjectFactory sharedFactory];
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
                    else{
                        if([self timelineObjectsDelegateImplementsSelector:@selector(timelineObjectsHaveBeenRemoved)]){
                            [self.timelineObjectsDelegate timelineObjectsHaveBeenRemoved];
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

#pragma mark - NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.duration forKey:kDuration];
    [aCoder encodeObject:self.tracks forKey:kTracks];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    if(self = [self init]){
        self.duration = [aDecoder decodeDoubleForKey:kDuration];
        
        self.tracks =  [aDecoder decodeObjectForKey:kTracks];
        
        for(VSTrack * track in self.tracks){
            [track addObserver:self forKeyPath:@"timelineObjects"
                          options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew
                          context:nil];
            
            if(track.trackID > self.lastTrackID){
                self.lastTrackID = track.trackID;
            }
        }
        
        [self initPlayHead];
    }
    return self;
}


#pragma mark - Methods

#pragma mark Tracks

-(BOOL) addNewTrackNamed:(NSString *)name ofType:(VSTrackType)type{
    VSTrack* newTrack = [[VSTrack alloc] initWithName:name trackID:[self nextAvailableTrackID] type:type];

    [self.tracks addObject:newTrack];
    
    [self addedTrack:self.tracks.lastObject];
    return YES;
}

-(void) addedTrack:(VSTrack*) newTrack{
    [newTrack addObserver:self forKeyPath:@"timelineObjects"
                  options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew
                  context:nil];
    
    if(newTrack.timelineObjects){
        if([self timelineObjectsDelegateImplementsSelector:@selector(timelineObjects:haveBeenAddedToTrack:)]){
            [self.timelineObjectsDelegate timelineObjects:newTrack.timelineObjects haveBeenAddedToTrack:newTrack];
        }
    }
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

-(VSTimelineObjectProxy*) createNewTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item positionedAtTime:(double)timePosition withDuration:(double)duration{
    
    NSImage* icon = [VSFileImageCreator createIconForTimelineObject:item.filePath];
    
    VSTimelineObjectProxy *newProxy = [[VSTimelineObjectProxy alloc] initWithName:item.name atTime:timePosition  duration:duration icon:icon];
    
    return newProxy;
    
}

#pragma mark Copy TimlineObjects

-(VSTimelineObject*) copyTimelineObject:(VSTimelineObject *)baseTimelineObject toTrack:(VSTrack *)track atPosition:(double)position withDuration:(double)duration{
    
    VSTimelineObject *copiedTimelineObject = [self.timelineObjectFactory createCopyOfTimelineObject:baseTimelineObject atStartTime:position withDuration:duration];
    // Adds the new object to the given track */
    [track addTimelineObject:copiedTimelineObject];
    
    return copiedTimelineObject;
}

-(VSTimelineObject*) copyTimelineObject:(VSTimelineObject *)baseTimelineObject toTrack:(VSTrack *)track atPosition:(double)position withDuration:(double)duration andRegisterUndoOperation:(NSUndoManager *)undoManager{
    
    VSTimelineObject *copiedTimelineObject = [self.timelineObjectFactory createCopyOfTimelineObject:baseTimelineObject atStartTime:position withDuration:duration];
    
    // Adds the new object to the given track */
    [track addTimelineObject:copiedTimelineObject andRegisterAtUndoManager:undoManager];
    
    return copiedTimelineObject;
}

#pragma mark Remove TimelineObjects

-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject fromTrack:(VSTrack *)track{
    return [track removeTimelineObject:aTimelineObject];
}

-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject fromTrack:(VSTrack *)track andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    return [track removeTimelineObject:aTimelineObject andRegisterAtUndoManager:undoManager];
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

//Todo: what happens with the track order if a new track is added?
- (NSArray *)timelineObjectsForTimestamp:(double)aTimestamp
{
    NSMutableArray *currentActiveTimeLineObjects = [[NSMutableArray alloc] init ];
    
    //iteratres through the timeline's tracks and adds the VSTimlineObject active at this timestamp to the currentActiveTimeLineObjects-Array
    for(NSInteger i = self.tracks.count - 1; i >= 0; i--){
        VSTrack *track = [self.tracks objectAtIndex:i];
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

-(void) timelineObjectsDelegateDidRegister{
    for(VSTrack *track in self.tracks){
        if(track.timelineObjects.count){
            if([self timelineObjectsDelegateImplementsSelector:@selector(timelineObjects:haveBeenAddedToTrack:)]){
                [self.timelineObjectsDelegate timelineObjects:track.timelineObjects haveBeenAddedToTrack:track];
            }
        }
    }
}

#pragma mark - Properties

-(id<VSTimelineTimelineObjectsDelegate>) timelineObjectsDelegate{
    return _timelineObjectsDelegate;
}

-(void) setTimelineObjectsDelegate:(id<VSTimelineTimelineObjectsDelegate>)timelineObjectsDelegate{
    _timelineObjectsDelegate = timelineObjectsDelegate;
    
    [self timelineObjectsDelegateDidRegister];
}

@end
