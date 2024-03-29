//
//  VSDevice.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDevice.h"

#import "VSDeviceParameter.h"
#import "VSDeviceManager.h"
#import "VSDocument.h"

@implementation VSDevice

#define kID @"ID"
#define kName @"Name"
#define kParameters @"Parameters"

-(id) initWithID:(NSString*) UUID andName:(NSString*) name{
    if(self = [super init]){
        self.name = name;
        self.ID = UUID;
        
        self.parameters = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


-(void) addParametersObject:(VSDeviceParameter *)object{
    [self.parameters  setObject:object forKey:object.identifier];
}

-(VSDeviceParameter*) parameterIdentifiedBy:(NSString*) identifier{
    return [self.parameters objectForKey:identifier];
}

-(VSDeviceParameter*)objectInParametersAtIndex:(NSUInteger)index{
    
    id objectAtIndex = [[self.parameters allValues] objectAtIndex:index];
    
    if(objectAtIndex){
        if([objectAtIndex isKindOfClass:[VSDeviceParameter class]]){
            return objectAtIndex;
        }
    }
    
    return nil;
}

#pragma mark - 
#pragma mark NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.ID forKey:kID];
//    [aCoder encodeObject:self.name forKey:kName];
//    [aCoder encodeObject:self.parameters forKey:kParameters];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    NSString *deviceID = [aDecoder decodeObjectForKey:kID];
    
    return [VSDeviceManager storedDeviceForID:deviceID];
}

-(NSUInteger) indexOfObjectInParameters:(VSDeviceParameter*) parameter{
    return [[self.parameters allKeys] indexOfObject:parameter.identifier];
}

-(BOOL) activateParameter:(VSDeviceParameter*) deviceParameter{
    
    BOOL result = false;
    
    if([[self.parameters allValues] containsObject:deviceParameter]){
        if([self delegateRespondsToSelector:@selector(registerDeviceParameter:ofDevice:)]){
            result = [self.delegate registerDeviceParameter:deviceParameter ofDevice:self];
        }
    }
    return result;
}

-(BOOL) deactivateParameter:(VSDeviceParameter*) deviceParameter{
    BOOL result = false;
    
    if([[self.parameters allValues] containsObject:deviceParameter]){
        if([self delegateRespondsToSelector:@selector(unregisterDeviceParameter:ofDevice:)]){
            result = [self.delegate unregisterDeviceParameter:deviceParameter ofDevice:self];
        }
    }
    return result;
}

#pragma mark - Private Methods

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSDeviceDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

@end
