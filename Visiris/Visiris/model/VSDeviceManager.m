//
//  VSDeviceManager.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceManager.h"

#import "VSCoreServices.h"

@implementation VSDeviceManager


@synthesize devices = _devices;


- (BOOL)addDevice:(VSDevice *)newDevice
{
    BOOL didAddDevice = NO;
    
    if (newDevice) {
        [self.devices addObject:newDevice];
        didAddDevice = YES;
    }else{
        DDLogError(@"Error adding new device: newDevice was nil - this will fail");
    }
    
    return didAddDevice;
}

- (NSUInteger)numberOfDevices
{
    return _devices.count;
}
@end
