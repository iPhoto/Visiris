//
//  VSTimelineObjectProxy.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 14.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectProxy.h"

#import "VSCoreServices.h"

@implementation VSTimelineObjectProxy

#define kStartTime @"StartTime"
#define kDuration @"Duration"
#define kName @"Name"
#define kIcon @"Icon"
#define kSelected @"Selected"
#define kTimelineObjectID @"TimelineObjectID"

#pragma mark- Init

-(id) initWithName:(NSString *)name atTime:(double)startTime duration:(double)duration icon:(NSImage *)icon{
    if(self = [super init]){
        self.startTime = startTime;
        self.duration = duration;
        self.icon = icon;
        self.name = name;
        self.selected = NO;
    }
    
    return self;
}

#pragma mark - NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.startTime forKey:kStartTime];
    [aCoder encodeDouble:self.duration forKey:kDuration];
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeObject:self.icon forKey:kIcon];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if(self = [self init]){
        self.startTime = [aDecoder decodeDoubleForKey:kStartTime];
        self.duration = [aDecoder decodeDoubleForKey:kDuration];
        self.name = [[aDecoder decodeObjectForKey:kName] copy];
        self.icon = [[aDecoder decodeObjectForKey:kIcon] copy];
    }
    return self;
}

#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSTimelineObjectProxy *copy = [[VSTimelineObjectProxy allocWithZone:zone] init];
    
    if(copy){
        copy.startTime = self.startTime;
        copy.duration = self.duration;
        copy.name = [self.name copy];
        copy.icon = [self.icon copy];
        copy.selected = self.selected;
        copy.timelineObjectID = self.timelineObjectID;
        
    }
    
    return copy;
}

-(void) dealloc{
    
}

#pragma mark - Methods

-(void) changeStartTime:(double)startTime andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] changeStartTime:self.startTime andRegisterAtUndoManager:undoManager];
    
    self.startTime = startTime;
}

-(void) changeDuration:(double)duration andRegisterAtUndoManager:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] changeDuration:self.duration andRegisterAtUndoManager:undoManager];
    
    self.duration = duration;
}

#pragma mark - Undo / Redo

-(void) setSelectedAndRegisterUndo:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] setUnselectedAndRegisterUndo:undoManager];
    self.selected = YES;
}

-(void) setUnselectedAndRegisterUndo:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] setSelectedAndRegisterUndo:undoManager];
    self.selected = NO;
}

#pragma mark - Properties

-(NSString*) startTimeString{
    return    [VSFormattingUtils formatedTimeStringFromMilliseconds:self.startTime formatString:@"HH:mm:ss:tt"];
}


@end
