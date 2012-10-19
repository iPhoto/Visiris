//
//  VSTrack.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrack.h"
#import "VSTimelineObject.h"

@interface VSTrack()


@end

@implementation VSTrack

#define kTimelineObjects @"TimelineObjects"
#define kName @"Name"
#define kType @"Type"
#define kTrackID @"TrackID"

@synthesize timelineObjects = _timelineObjects;

#pragma mark - Init

-(id) initWithName:(NSString*) name trackID:(NSInteger)trackID type:(VSTrackType)type{
    if(self = [self init]){
        self.name = name;
        self.type = type;
        self.trackID = trackID;
        
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        _timelineObjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - NSObject

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
}

#pragma mark - NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_timelineObjects forKey:kTimelineObjects];
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeInteger:self.trackID forKey:kTrackID];
    [aCoder encodeInteger:self.type forKey:kType];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    if( self = [self init]){
        NSArray *storedTimelineObjects = [aDecoder decodeObjectForKey:kTimelineObjects];
        if(storedTimelineObjects.count)
        {
            [self.timelineObjects addObjectsFromArray:storedTimelineObjects];
        }
        self.name = [aDecoder decodeObjectForKey:kName];
        self.trackID = [aDecoder decodeIntegerForKey:kTrackID];
        self.type = [aDecoder decodeIntegerForKey:kType];
    }
    
    return self;
}

#pragma mark - Methods

-(BOOL) addTimelineObject:(VSTimelineObject *)timelineObject{
    DDLogInfo(@"observers: %@",self.observationInfo);
    [self.timelineObjects addObject:timelineObject];
    return YES;
}

-(void) addTimelineObjectsObject:(NSArray *)object{
    [self.timelineObjects addObjectsFromArray:object];
}

-(BOOL) removeTimelineObject:(VSTimelineObject *)aTimelineObject{
    if([self.timelineObjects containsObject:aTimelineObject]){
        
        [self.timelineObjects removeObject:aTimelineObject];
        
        return YES;
    }
    else{
        return NO;
    }
}

//TODO: Faster algorithm to find the current VSTimelineObject
-(VSTimelineObject*)timelineObjectAtTimestamp:(double)aTimestamp{
    for (VSTimelineObject *timelineObject in self.timelineObjects){
        if(timelineObject.startTime <= aTimestamp && timelineObject.endTime >= aTimestamp){
            return timelineObject;
        }
    }
    
    return nil;
}

#pragma mark Undo

-(BOOL)removeTimelineObject:(VSTimelineObject *)aTimelineObject andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    BOOL result = [self removeTimelineObject:aTimelineObject];
    
    
    if(result){
        //        [undoManager registerUndoWithTarget:self selector:@selector(addTimelineObject:) object:aTimelineObject];
    }
    
    return result;
}

-(void) removeSelectedTimelineObjectsAndRegisterAtUndoManager:(NSUndoManager *)undoManager{
    NSArray *selectedTimelineObjects = [self selectedTimelineObjects];
    
    for(VSTimelineObject *timelineObject in selectedTimelineObjects){
        [self removeTimelineObject:timelineObject andRegisterAtUndoManager:undoManager];
    }
}

-(BOOL) addTimelineObject:(VSTimelineObject *)timelineObject andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    BOOL result = [self addTimelineObject:timelineObject];
    
    if(result){
        //        [undoManager registerUndoWithTarget:self selector:@selector(removeTimelineObject:) object:timelineObject];
    }
    
    return result;
}

#pragma mark TimelineObject Selection

-(void) selectTimelineObject:(VSTimelineObject *)timelineObjectToSelect{
    if([self.timelineObjects containsObject:timelineObjectToSelect]){
        timelineObjectToSelect.selected = YES;
    }
}

-(void) unselectTimelineObject:(VSTimelineObject *)timelineObjectToUnselect{
    if([self.timelineObjects containsObject:timelineObjectToUnselect]){
        timelineObjectToUnselect.selected = NO;
    }
}

-(void) unselectAllTimelineObjects{
    if(self.timelineObjects && self.timelineObjects.count > 0){
        for(VSTimelineObject *timelineObject in self.timelineObjects){
            timelineObject.selected = NO;
        }
    }
}

-(NSArray *) selectedTimelineObjects{
    NSIndexSet *indexSet = [self.timelineObjects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObject class]]){
            return ((VSTimelineObject*) obj).selected;
        }
        return NO;
    }];
    
    return [self.timelineObjects objectsAtIndexes:indexSet];
}

#pragma mark - Properties

-(NSMutableArray*)timelineObjects{
    return [self mutableArrayValueForKey:@"timelineObjects"];
}



@end
