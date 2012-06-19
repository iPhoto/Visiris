//
//  VSTimelineObject.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObject.h"

#import "VSProjectItem.h"
#import "VSTimelineObjectSource.h"
#import "VSSourceSupplier.h"
#import "VSFrameSourceSupplier.h"
#import "VisirisCore/VSCoreHandover.h"
#import "VSParameter.h"
#import "VisirisCore/VSFrameCoreHandover.h"

@implementation VSTimelineObject

@synthesize sourceObject        = _sourceObject;
@synthesize startTime           = _startTime;
@synthesize duration            = _duration;
@synthesize name                = _name;
@synthesize icon                = _icon;
@synthesize supplier            = _supplier;
@synthesize textureID           = _textureID;
@synthesize timelineObjectID    = _timelineObjectID;


#pragma mark - Init
-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon objectID:(NSInteger)objectID{
    if(self=[super initWithName:sourceObject.projectItem.name atTime:-1 duration:sourceObject.projectItem.duration icon:icon]){
        self.sourceObject = sourceObject;
        self.timelineObjectID = objectID;
    }
    
    return self;
}

#pragma mark - Methods

-(double) endTime{
    return self.startTime + self.duration;
}

- (VSCoreHandover *)handoverForTimestamp:(double)aTimestamp frameSize:(NSSize)aFrameSize isPlaying:(BOOL)playing{
    
    VSCoreHandover *coreHandover = nil;
    
    double localTimestamp = [self convertGlobalTimestampToLocalTimestamp:aTimestamp];
    //TODO richtiges corehandover basteln
    if ([self.supplier isKindOfClass:[VSFrameSourceSupplier class]] ) {
        coreHandover = [[VSFrameCoreHandover alloc] initWithFrame:[(VSFrameSourceSupplier *)self.supplier getFrameForTimestamp:localTimestamp isPlaying:playing] andAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp] forTextureID:self.textureID forTimestamp:localTimestamp forId: self.timelineObjectID];
    }
    else {
        DDLogInfo(@"Its an audio file");
    }
    
    return coreHandover;
}

-(NSDictionary *) parameters{
    if(!self.sourceObject)
        return nil;
        
    return self.sourceObject.parameters;
}

-(NSArray *) visibleParameters{
    NSSet *set = [self.sourceObject.parameters keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[VSParameter class]]){
            if(!((VSParameter*) obj).hidden){
                return YES;
            }
        }
        return NO;
    }];
    
    NSString *notFoundMarker = @"not found";
    
    NSArray *tmpArray = [self.sourceObject.parameters objectsForKeys:[set allObjects] notFoundMarker:notFoundMarker];
    tmpArray = [tmpArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:YES]]];
    
    return tmpArray;
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


- (double)convertGlobalTimestampToLocalTimestamp:(double)aGlobalTimestamp
{
    return aGlobalTimestamp - self.startTime;
}

@end
