//
//  VSDeviceAnimation.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSDevice;


/**
 * The VSDeviceParameterMapper is the connector between parameter and device
 *
 * !!!! Pleas Add more Here !!!!
 */
@interface VSDeviceParameterMapper : NSObject

/** The device the mapper takes it values from */
@property (weak) VSDevice *device;

/**
 * Inits the VSDeviceParameterMapper with the device it is the connector for
 * @param aDevice Device the VSDeviceParameterMapper is the connector for.
 * @return self
 */
-(id) initWithDevice:(VSDevice*) aDevice;

@end
