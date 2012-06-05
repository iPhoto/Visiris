//
//  VSTrack.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrack.h"
#import "VSTimelineObject.h"


@implementation VSTrack
@synthesize timelineObjects = _timelineObjects;
@synthesize name = _name;
@synthesize type=_type;

#pragma mark - Init

-(id) initWithName:(NSString*) name type:(VSTrackType) type{
    if(self = [super init]){
        self.name = name;
        self.type = type;
        
        _timelineObjects = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

#pragma mark - NSObject

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
}



#pragma mark - Methods

-(BOOL) addTimelineObject:(VSTimelineObject *)timelineObject{
    [self.timelineObjects addObject:timelineObject];
    [timelineObject addObserver:self forKeyPath:@"parameters" options:0 context:nil];
    return YES;
}


-(BOOL) removTimelineObject:(VSTimelineObject *)aTimelineObject{
    if([self.timelineObjects containsObject:aTimelineObject]){
        [self.timelineObjects removeObject:aTimelineObject];
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - Undo

-(BOOL)removTimelineObject:(VSTimelineObject *)aTimelineObject andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    BOOL result = [self removTimelineObject:aTimelineObject];
    
    if(result){
        [[undoManager prepareWithInvocationTarget:self] addTimelineObject:aTimelineObject andRegisterAtUndoManager:undoManager];
    }
    
    return result;
}

-(BOOL) addTimelineObject:(VSTimelineObject *)timelineObject andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    BOOL result = [self addTimelineObject:timelineObject];
    
    if(result){
        [[undoManager prepareWithInvocationTarget:self] removTimelineObject:timelineObject andRegisterAtUndoManager:undoManager];
    }
    
    return result;
}

#pragma mark - TimelineObject Selection

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
