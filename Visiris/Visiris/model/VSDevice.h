//
//  VSDevice.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@class VSDeviceParameter;

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

/** Stores the parameters defined for this device */
@property (strong) NSMutableDictionary *parameters;

/** indicates wheter the device is active or not.*/
@property BOOL active;

@property (strong) NSString *name;

@property NSString *ID;

@end
