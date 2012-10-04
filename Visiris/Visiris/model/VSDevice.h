//
//  VSDevice.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSDeviceParameter;
@class VSDevice;

@protocol VSDeviceDelegate <NSObject>

-(BOOL) registerDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device;

-(BOOL) unregisterDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device;

@end

/**
 * A VSDevice represents an external Device like Kinect, Ardunio.
 *
 * VsDevice manages the parameters of the Device and its settings
 */
@interface VSDevice : NSObject

-(id) initWithID:(NSString*) UUID andName:(NSString*) name;

-(void) addParametersObject:(VSDeviceParameter *)object;

-(VSDeviceParameter*)objectInParametersAtIndex:(NSUInteger)index;

-(NSUInteger) indexOfObjectInParameters:(VSDeviceParameter*) parameter;

-(BOOL) activateParameter:(VSDeviceParameter*) deviceParameter;

-(BOOL) deactivateParameter:(VSDeviceParameter*) deviceParameter;

/** Stores the parameters defined for this device */
@property (strong) NSMutableDictionary *parameters;

/** indicates wheter the device is active or not.*/
@property BOOL active;

@property (strong) NSString *name;

@property NSString *ID;

@property id<VSDeviceDelegate> delegate;

@property id currentValue;

@end
