//
//  VSDeviceAnimation.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSCoreServices.h"

@class VSDeviceParameter;
@class VSDevice;

/**
 * The VSDeviceParameterMapper is the connector between parameter and device
 */
@interface VSDeviceParameterMapper : NSObject

@property VSDeviceParameter *deviceParameter;
@property VSDevice *device;
@property VSRange parameterRange;
@property VSRange deviceParameterRange;

- (id)initWithDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device deviceParameterRange:(VSRange) deviceParameterRange andParameterRange:(VSRange) parameterRange;

- (float)currentMappedParameterFloatValue;

-(BOOL) currentDeviceParameterBoolValue;

-(NSString*) currentStringValue;

@end
