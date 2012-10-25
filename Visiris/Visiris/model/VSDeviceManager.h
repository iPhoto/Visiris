//
//  VSDeviceManager.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSDevice.h"

@protocol VSDeviceParameterRegistrationDelegate <NSObject>

-(BOOL) registerValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString*) identifier;

-(BOOL) unregisterValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString*) identifier;


@end

#import "VSExternalInputManager.h"


@class VSDevice;
@class VSDeviceRepresentation;
@class VSExternalInputManager;
/**
 * VSDeviceManager manages all VSDevices and provides them with values for their parameters
 */
@interface VSDeviceManager : NSObject<VSDeviceDelegate>

/** Stores the devices */
@property (strong) NSMutableArray *devices;

@property (strong) NSMutableArray *deviceRepresentations;

@property (weak) id<VSDeviceParameterRegistrationDelegate> deviceRegisitratingDelegate;

@property (strong,readonly) NSMutableArray *availableInputsRepresentation;

@property (weak) VSExternalInputManager *externalInputManager;

+(VSDevice*) storedDeviceForID:(NSString*) idString;

-(VSDeviceRepresentation*) objectInDeviceRepresentationsAtIndex:(NSUInteger)index;

-(VSDevice*)objectInDevicesAtIndex:(NSUInteger)index;

-(void) addDevicesObject:(VSDevice *)object;

-(NSUInteger)numberOfDevices;

-(VSDevice*) deviceRepresentedBy:(VSDeviceRepresentation*) deviceRepresentation;

-(BOOL) createDeviceWithName:(NSString*) deviceName andParameters:(NSArray*) parameters;

-(void) resetAvailableInputsRepresentation;

-(VSDevice*) deviceIdentifiedByID:(NSString*) idString;

@end
