//
//  VSDeviceParamterUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.10.12.
//
//

#import "VSDeviceParamterUtils.h"

@implementation VSDeviceParamterUtils

static NSMutableDictionary *validDevicParameterTypesForParameterDataTypes;


+(void) initialize{
    validDevicParameterTypesForParameterDataTypes = [[NSMutableDictionary alloc] init];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeFloat]];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeBool]];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeString]];
    
    [self addOSCParameterType:OSCValFloat validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:OSCValInt validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:OSCValDouble validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:OSCValTimeTag validForParameterType:VSParameterDataTypeFloat];
    
    [self addOSCParameterType:OSCValString validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValDouble validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValInt validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCVal64Int validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValBool validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValChar validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValBool validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValFloat validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:OSCValTimeTag validForParameterType:VSParameterDataTypeString];
    
    [self addOSCParameterType:OSCValBool validForParameterType:VSParameterDataTypeBool];
    
}

+(void) addOSCParameterType:(OSCValueType)oscValueType validForParameterType:(VSParameterDataType)parameterDataType{
    NSMutableArray *oscValueTypes = [validDevicParameterTypesForParameterDataTypes objectForKey:[NSNumber numberWithInt:parameterDataType]];
    
    if(oscValueTypes){
        [oscValueTypes addObject:[NSNumber numberWithInt:oscValueType]];
    }
    
}

+(BOOL) oscParameterType:(OSCValueType)oscValueType validForParameterType:(VSParameterDataType)parameterDataType{
    
    BOOL result = false;
    
    NSMutableArray *oscValueTypes = [validDevicParameterTypesForParameterDataTypes objectForKey:[NSNumber numberWithInt:parameterDataType]];
    
    if(oscValueTypes){
//        oscValueTypes
    }
    
}

@end
