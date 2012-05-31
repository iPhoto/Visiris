//
//  VSDeviceManager.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * VSDeviceManager manages all VSDevices and provides them with values for their parameters
 */
@interface VSDeviceManager : NSObject

/** Stores the devices */
@property (strong) NSMutableArray *devices;

@end
