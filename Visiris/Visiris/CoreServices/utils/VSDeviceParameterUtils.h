//
//  VSDeviceParameterUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

#import <Foundation/Foundation.h>

#import <VVOSC/VVOSC.h>

#import "VSParameterDataType.h"

typedef enum {
    VSDeviceParameterDataypeOSCFloat,
    VSDeviceParameterDataypeOSCInt,
    VSDeviceParameterDataypeOSCString,
    VSDeviceParameterDataypeOSCTimeTag,
    VSDeviceParameterDataypeOSC64Int,
    VSDeviceParameterDataypeOSCDouble,
    VSDeviceParameterDataypeOSCChar,
    VSDeviceParameterDataypeOSCColor,
    VSDeviceParameterDataypeOSCMidi,
    VSDeviceParameterDataypeOSCBool,
    VSDeviceParameterDataypeOSCNil,
    VSDeviceParameterDataypeOSCInfintiy,
    VSDeviceParameterDataypeOSCBlob
} VSDeviceParameterDataype;

@interface VSDeviceParameterUtils : NSObject

+(BOOL) deviceParameterDataype:(VSDeviceParameterDataype) deviceParameterValueType validForParameterType:(VSParameterDataType) parameterDataType;

+(VSDeviceParameterDataype) deviceParameterDatatypeForString:(NSString*) stringName andError:(NSError**) error;

+ (NSString *) nameForOSCType:(OSCValueType)type;

+ (VSDeviceParameterDataype) deviceParameterDatatypeForOSCParameterValueType:(OSCValueType) oscValueType;

+ (NSString *)stringForDeviceParameterDataType:(VSDeviceParameterDataype)dataType;

+ (BOOL)isDeviceParameterDatatypeSupportingRanges:(VSDeviceParameterDataype)dataType;

@end
