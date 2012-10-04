//
//  VSDeviceAnimation.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSCoreServices.h"

@class VSDevice;

/**
 * The VSDeviceParameterMapper is the connector between parameter and device
 */
@interface VSDeviceParameterMapper : NSObject

- (float)mapValue:(float)value fromRange:(VSRange)inRange toRange:(VSRange)outRange;

@end
