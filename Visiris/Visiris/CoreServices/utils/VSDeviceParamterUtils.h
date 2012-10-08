//
//  VSDeviceParamterUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.10.12.
//
//

#import <Foundation/Foundation.h>

#import <VVOSC/VVOSC.h>

#import "VSCoreServices.h"

@interface VSDeviceParamterUtils : NSObject

+(BOOL) oscParameterType:(OSCValueType) oscValueType validForParameterType:(VSParameterDataType) parameterDataType;

@end
