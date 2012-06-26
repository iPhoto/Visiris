//
//  VSTimelineObjectProxy.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 14.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectProxy.h"

@implementation VSTimelineObjectProxy
@synthesize startTime           = _startTime;
@synthesize duration            = _duration;
@synthesize name                = _name;
@synthesize icon                = _icon;
@synthesize selected            = _selected;
@synthesize timelineObjectID    = _timelineObjectID;

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

//-(void) encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeDouble:self.startTime forKey:@"startTime"];
//    [aCoder encodeDouble:self.duration forKey:@"duration"];
//    [aCoder encodeObject:self.name forKey:@"name"];
//    [aCoder encodeObject:self.icon forKey:@"icon"];
//    [aCoder encodeBool:self.selected forKey:@"selected"];
//    [aCoder encodeInt:self.timelineObjectID forKey:@"timelineObjectID"];
//}
//
//-(id) initWithCoder:(NSCoder *)aDecoder{
//    
//}

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

-(void) changeName:(NSString *)newName andRegisterAt:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] changeName:self.name andRegisterAt:undoManager];
    self.name = newName;
}



@end
