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
@interface VSDeviceParameterMapper : NSObject<NSCopying, NSCoding>

@property (weak) VSDeviceParameter *deviceParameter;
@property (weak) VSDevice *device;
@property (assign) VSRange parameterRange;
@property (assign) VSRange deviceParameterRange;
@property (assign) BOOL hasRanges;
@property (assign) float smoothing;


- (id)initWithDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device deviceParameterRange:(VSRange) deviceParameterRange andParameterRange:(VSRange) parameterRange;

- (id)initWithDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device;

- (float)currentMappedParameterFloatValue;

-(BOOL) currentDeviceParameterBoolValue;

-(NSString*) currentStringValue;

-(BOOL) activateDeviceParameter;

-(BOOL) deactivateDeviceParameter;

@end
