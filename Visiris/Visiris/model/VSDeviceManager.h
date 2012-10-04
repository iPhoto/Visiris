//
//  VSDeviceManager.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VSDevice;
@class VSDeviceRepresentation;
/**
 * VSDeviceManager manages all VSDevices and provides them with values for their parameters
 */
@interface VSDeviceManager : NSObject

/** Stores the devices */
@property (strong) NSMutableArray *devices;

@property (strong) NSMutableArray *deviceRepresentations;

-(VSDeviceRepresentation*) objectInDeviceRepresentationsAtIndex:(NSUInteger)index;

-(VSDevice*)objectInDevicesAtIndex:(NSUInteger)index;

-(void) addDevicesObject:(VSDevice *)object;

- (NSUInteger)numberOfDevices;

-(VSDevice*) deviceRepresentedBy:(VSDeviceRepresentation*) deviceRepresentation;

@end
