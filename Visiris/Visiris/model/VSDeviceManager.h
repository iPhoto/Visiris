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

-(BOOL) registerValue:(id) parameterCurrentValue forAddress:(NSString*) parameterAddress;

-(BOOL) unregisterValue:(id) parameterCurrentValue forAddress:(NSString*) parameterAddress;

@end


@class VSDevice;
@class VSDeviceRepresentation;
/**
 * VSDeviceManager manages all VSDevices and provides them with values for their parameters
 */
@interface VSDeviceManager : NSObject<VSDeviceDelegate>

/** Stores the devices */
@property (strong) NSMutableArray *devices;

@property (strong) NSMutableArray *deviceRepresentations;

@property (weak) id<VSDeviceParameterRegistrationDelegate> deviceRegisitratingDelegate;

-(VSDeviceRepresentation*) objectInDeviceRepresentationsAtIndex:(NSUInteger)index;

-(VSDevice*)objectInDevicesAtIndex:(NSUInteger)index;

-(void) addDevicesObject:(VSDevice *)object;

-(NSUInteger)numberOfDevices;

-(VSDevice*) deviceRepresentedBy:(VSDeviceRepresentation*) deviceRepresentation;

@end
