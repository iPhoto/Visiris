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
@interface VSDevice : NSObject<NSCoding>

-(id) initWithID:(NSString*) UUID andName:(NSString*) name;

-(void) addParametersObject:(VSDeviceParameter *)object;

-(VSDeviceParameter*)objectInParametersAtIndex:(NSUInteger)index;

-(NSUInteger) indexOfObjectInParameters:(VSDeviceParameter*) parameter;

-(VSDeviceParameter*) parameterIdentifiedBy:(NSString*) identifier;

-(BOOL) activateParameter:(VSDeviceParameter*) deviceParameter;

-(BOOL) deactivateParameter:(VSDeviceParameter*) deviceParameter;

/** Stores the parameters defined for this device */
@property (strong) NSMutableDictionary *parameters;

/** indicates wheter the device is active or not.*/
@property (assign) BOOL active;

@property (strong) NSString *name;

@property (strong) NSString *ID;

@property (weak) id<VSDeviceDelegate> delegate;

@end
