//
//  VSDevice.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A VSDevice represents an external Device like Kinect, Ardunio.
 *
 * VsDevice manages the parameters of the Device and its settings
 */
@interface VSDevice : NSObject

/** Stores the parameters defined for this device */
@property (strong) NSDictionary *parameters;

/** indicates wheter the device is active or not.*/
@property BOOL active;

@property (strong) NSString *name;

@property NSUInteger ID;

@end
