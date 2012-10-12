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
#import "VSVideoSourceSupplier.h"
#import "VisirisCore/VSAudioCoreHandover.h"
#import "VisirisCore/VSVideoCoreHandover.h"
#import "VSDevice.h"

#import "VSCoreServices.h"

@interface VSTimelineObject()



@end

@implementation VSTimelineObject

@synthesize devices = _devices;

-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon objectID:(NSInteger)objectID{
    if(self=[super initWithName:sourceObject.projectItem.name atTime:-1 duration:sourceObject.projectItem.duration icon:icon]){
        self.sourceObject = sourceObject;
        self.timelineObjectID = objectID;
        _devices = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(id) initWithSourceObject:(VSTimelineObjectSource*) sourceObject icon:(NSImage *)icon objectID:(NSInteger)objectID andDevices:(NSMutableArray*) devices{
    if(self=[super initWithName:sourceObject.projectItem.name atTime:-1 duration:sourceObject.projectItem.duration icon:icon]){
        self.sourceObject = sourceObject;
        self.timelineObjectID = objectID;
        _devices = devices;
    }
    
    return self;
}

- (void)dealloc
{
    DDLogInfo(@"dealloc");
}


#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
//    VSTimelineObjectProxy *superCopy = [super copyWithZone:zone];
    
    VSTimelineObject *copy = [[VSTimelineObject alloc] initWithSourceObject:self.sourceObject
                                                                       icon:self.icon objectID:self.timelineObjectID
                                                                 andDevices:self.devices];
    
    if(copy){
        
        copy.supplier = [[[self.supplier class] alloc] initWithTimelineObject:copy];
        
        copy.startTime = self.startTime;
        copy.duration = self.duration;
        copy.selected = self.selected;
        

    }
    
    return copy;
}

#pragma mark - Methods

-(double) endTime{
    return self.startTime + self.duration;
}

- (VSCoreHandover *)handoverForTimestamp:(double)aTimestamp frameSize:(NSSize)aFrameSize withPlayMode:(VSPlaybackMode)mode{
    
    VSCoreHandover *coreHandover = nil;
        
    double localTimestamp = [self localTimestampOfGlobalTimestamp:aTimestamp];
    
    if ([self.supplier isKindOfClass:[VSFrameSourceSupplier class]] ) {
        
        
        if ([self.supplier isKindOfClass:[VSVideoSourceSupplier class]]) {
            
            VSVideoSourceSupplier *temp = (VSVideoSourceSupplier *)self.supplier;
            coreHandover = [[VSVideoCoreHandover alloc] initWithFrame:[temp getFrameForTimestamp:localTimestamp withPlayMode:mode]
                                                        andAttributes:[temp getAtrributesForTimestamp:localTimestamp]
                                                         forTimestamp:[temp videoTimestamp]
                                                                forId:self.timelineObjectID
                                                            withAudio:temp.hasAudio];
            
            
        }
        else {
            coreHandover = [[VSFrameCoreHandover alloc] initWithFrame:[(VSFrameSourceSupplier *)self.supplier getFrameForTimestamp:localTimestamp withPlayMode:mode]
                                                        andAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp]
                                                         forTimestamp:localTimestamp
                                                                forId:self.timelineObjectID];
        }
    }
    else if ([self.supplier isKindOfClass:[VSQuartzComposerSourceSupplier class]]){
        coreHandover = [[VSQuartzComposerHandover alloc] initWithAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp]
                                                               forTimestamp:localTimestamp
                                                                andFilePath:[(VSQuartzComposerSourceSupplier *)self.supplier getQuartzComposerPatchFilePath]
                                                                      forId:self.timelineObjectID];
    }
    else if ([self.supplier isKindOfClass:[VSAudioSourceSupplier class]]) {
        coreHandover = [[VSAudioCoreHandover alloc] initWithAttributes:[self.supplier getAtrributesForTimestamp:localTimestamp]
                                                          forTimestamp:[(VSAudioSourceSupplier *)self.supplier convertToAudioTimestamp:localTimestamp]
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


-(void) changeName:(NSString *)newName andRegisterAt:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] changeName:self.name andRegisterAt:undoManager];
  //  self.name = newName;
}

- (double)localTimestampOfGlobalTimestamp:(double)aGlobalTimestamp{
    if(aGlobalTimestamp < self.startTime || aGlobalTimestamp > self.endTime){
        return -1.0;
    }
    
    return aGlobalTimestamp - self.startTime;;
}

-(double) globalTimestampOfLocalTimestamp:(double)aLocalTimestamp{
    return aLocalTimestamp + self.startTime;
}

-(void) addDevicesObject:(VSDevice *)object{
    
    if(!self.devices){
        _devices = [[NSMutableArray alloc] init];
    }
    
    if(object){
        if(![self.devices containsObject:object]){
            [self.devices addObject:object];
        }
    }
    else{
        DDLogError(@"Device to add was nil");
    }
}

-(NSArray*) devicesAtIndexes:(NSIndexSet *)indexes{
    return [self.devices objectsAtIndexes:indexes];
}

#pragma mark - Properties

-(double) sourceDuration{
    return self.sourceObject.projectItem.duration;
}

-(NSMutableArray*) devices
{
    NSMutableArray *result= [self mutableArrayValueForKey:@"devices"];
    return result;
}


-(VSFileType*) fileType{
    return self.sourceObject.projectItem.fileType;
}

-(NSString*) filePath{
    return self.sourceObject.filePath;
}

@end
