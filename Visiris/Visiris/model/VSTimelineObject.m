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
#import "VSFrameSourceSupplier.h"
#import "VSQuartzComposerSourceSupplier.h"
#import "VisirisCore/VSCoreHandover.h"
#import "VSParameter.h"
#import "VisirisCore/VSFrameCoreHandover.h"
#import "VisirisCore/VSQuartzComposerHandover.h"
#import "VSSourceSupplier.h"
#import "VSAudioSourceSupplier.h"
#import "VisirisCore/VSAudioCoreHandover.h"

@implementation VSTimelineObject

@synthesize sourceObject        = _sourceObject;
@synthesize startTime           = _startTime;
@synthesize duration            = _duration;
@synthesize name                = _name;
@synthesize icon                = _icon;
@synthesize supplier            = _supplier;
@synthesize textureID           = _textureID;


#pragma mark - Init
-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon objectID:(NSInteger)objectID{
    if(self=[super initWithName:sourceObject.projectItem.name atTime:-1 duration:sourceObject.projectItem.duration icon:icon]){
        self.sourceObject = sourceObject;
        self.timelineObjectID = objectID;
    }
    
    return self;
}

//#pragma mark - NSCoding implementation
//
//-(void) encodeWithCoder:(NSCoder *)aCoder{
//    
//    [aCoder encodeObject:self.sourceObject forKey:@"sourceObject"];
//    [aCoder encodeInt:self.textureID forKey:@"textureID"];
//}
//
//-(id) initWithCoder:(NSCoder *)aDecoder{
//    self.sourceObject = [aDecoder decodeObjectForKey:@"sourceObject"];
//    self.textureID = [aDecoder decodeIntForKey:@"textureID"];
//    
//    self.supplier = [[VSSourceSupplier alloc] initWithTimelineObject:self];
//    
//    return self;
//}

#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSTimelineObjectProxy *superCopy = [super copyWithZone:zone];
    
    VSTimelineObject *copy = [[VSTimelineObject allocWithZone:zone] init];
    
    if(superCopy){
        
        copy.sourceObject = [self.sourceObject copy];
        copy.supplier = [[[self.supplier class] alloc] initWithTimelineObject:copy];
        
        copy.startTime = superCopy.startTime;
        copy.duration = superCopy.duration;
        copy.name = superCopy.name;
        copy.icon = superCopy.icon;
        copy.selected = superCopy.selected;
        copy.timelineObjectID = superCopy.timelineObjectID;
        copy.textureID = self.textureID;
    }
    
    return copy;
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
        coreHandover = [[VSFrameCoreHandover alloc] initWithFrame:[(VSFrameSourceSupplier *)self.supplier getFrameForTimestamp:localTimestamp isPlaying:playing]
                                                    andAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp]
                                                     forTextureID:self.textureID
                                                     forTimestamp:localTimestamp
                                                            forId:self.timelineObjectID];
    }
    else if ([self.supplier isKindOfClass:[VSQuartzComposerSourceSupplier class]]){
        coreHandover = [[VSQuartzComposerHandover alloc] initWithAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp]
                                                               forTimestamp:localTimestamp
                                                                andFilePath:[(VSQuartzComposerSourceSupplier *)self.supplier getQuartzComposerPatchFilePath] 
                                                                      forId:self.timelineObjectID
                                                               forTextureID:self.textureID];
    }
    else if ([self.supplier isKindOfClass:[VSAudioSourceSupplier class]]) {
        coreHandover = [[VSAudioCoreHandover alloc] initWithAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp] 
                                                          forTimestamp:localTimestamp
                                                                 forId:self.timelineObjectID];
    }
    else {
        DDLogInfo(@"unsuported file/handover");
    }
    
    return coreHandover;
}

-(NSDictionary *) parameters{
    if(!self.sourceObject)
        return nil;
    
    return self.sourceObject.parameters;
}

-(NSArray *) visibleParameters{
    return [self.sourceObject visibleParameters];
}



- (double)convertGlobalTimestampToLocalTimestamp:(double)aGlobalTimestamp{
    double localTimestamp = aGlobalTimestamp - self.startTime;
    
    localTimestamp = localTimestamp <= self.sourceObject.projectItem.duration ? localTimestamp :  fmod(localTimestamp, self.sourceObject.projectItem.duration);
    
    return localTimestamp;
    
}

-(void) changeName:(NSString *)newName andRegisterAt:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] changeName:self.name andRegisterAt:undoManager];
    self.name = newName;
}

@end
