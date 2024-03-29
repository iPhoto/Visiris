//
//  VSDeviceParamterUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.10.12.
//
//

#import "VSDeviceParameterUtils.h"

#import <VVOSC/VVOSC.h>

#import "VSCoreServices.h"

@implementation VSDeviceParameterUtils

static NSMutableDictionary *validDevicParameterTypesForParameterDataTypes;

static NSMutableDictionary *genericDeviceDataTypeForVSDeviceParameterDataype;

static NSMutableDictionary *deviceParameterTypeOfString;


+(void) initialize{
    
    
    deviceParameterTypeOfString = [[NSMutableDictionary alloc] init];
    
    
    
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCFloat]
                                    forKey:@"oscFloat"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCInt]
                                    forKey:@"oscInt"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCString]
                                    forKey:@"oscString"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCTimeTag]
                                    forKey:@"oscTimeTag"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSC64Int]
                                    forKey:@"osc64Int"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCDouble]
                                    forKey:@"oscDouble"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCChar]
                                    forKey:@"oscChar"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCColor]
                                    forKey:@"oscColor"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCMidi]
                                    forKey:@"oscMidi"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCBool]
                                    forKey:@"oscBool"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCNil]
                                    forKey:@"oscNil"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCInfintiy]
                                    forKey:@"oscInfintiy"];
    [deviceParameterTypeOfString setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCBlob]
                                    forKey:@"oscBlob"];
    
    
    
    genericDeviceDataTypeForVSDeviceParameterDataype = [[NSMutableDictionary alloc] init];
    
    
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCFloat]
                                                         forKey:[NSNumber numberWithInt:OSCValFloat]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCInt]
                                                         forKey:[NSNumber numberWithInt:OSCValInt]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCString]
                                                         forKey:[NSNumber numberWithInt:OSCValString]];
    
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCTimeTag]
                                                         forKey:[NSNumber numberWithInt:OSCValTimeTag]];
    
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSC64Int]
                                                         forKey:[NSNumber numberWithInt:OSCVal64Int]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCDouble]
                                                         forKey:[NSNumber numberWithInt:OSCValDouble]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCChar]
                                                         forKey:[NSNumber numberWithInt:OSCValChar]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCColor]
                                                         forKey:[NSNumber numberWithInt:OSCValColor]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCMidi]
                                                         forKey:[NSNumber numberWithInt:OSCValMIDI]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCBool]
                                                         forKey:[NSNumber numberWithInt:OSCValBool]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCNil]
                                                         forKey:[NSNumber numberWithInt:OSCValNil]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCInfintiy]
                                                         forKey:[NSNumber numberWithInt:OSCValInfinity]];
    [genericDeviceDataTypeForVSDeviceParameterDataype setObject:[NSNumber numberWithInt:VSDeviceParameterDataypeOSCBlob]
                                                         forKey:[NSNumber numberWithInt:OSCValBlob]];
    
    
    validDevicParameterTypesForParameterDataTypes = [[NSMutableDictionary alloc] init];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeFloat]];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeBool]];
    
    [validDevicParameterTypesForParameterDataTypes setObject:[[NSMutableArray alloc] init]
                                                      forKey: [NSNumber numberWithInt:VSParameterDataTypeString]];
    
    [self addOSCParameterType:VSDeviceParameterDataypeOSCFloat validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCInt validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCDouble validForParameterType:VSParameterDataTypeFloat];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCTimeTag validForParameterType:VSParameterDataTypeFloat];
    
    [self addOSCParameterType:VSDeviceParameterDataypeOSCString validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCDouble validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCInt validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSC64Int validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCBool validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCChar validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCFloat validForParameterType:VSParameterDataTypeString];
    [self addOSCParameterType:VSDeviceParameterDataypeOSCTimeTag validForParameterType:VSParameterDataTypeString];
    
    [self addOSCParameterType:VSDeviceParameterDataypeOSCBool validForParameterType:VSParameterDataTypeBool];
    
}

+(void) addOSCParameterType:(OSCValueType)oscValueType validForParameterType:(VSParameterDataType)parameterDataType{
    NSMutableArray *oscValueTypes = [validDevicParameterTypesForParameterDataTypes objectForKey:[NSNumber numberWithInt:parameterDataType]];
    
    if(oscValueTypes){
        [oscValueTypes addObject:[NSNumber numberWithInt:oscValueType]];
    }
    
}

+(BOOL) deviceParameterDataype:(VSDeviceParameterDataype) deviceParameterValueType validForParameterType:(VSParameterDataType) parameterDataType{
    
    BOOL result = NO;
    
    NSArray *validDeviceParameterDataTypes = [validDevicParameterTypesForParameterDataTypes objectForKey:[NSNumber numberWithInt:parameterDataType]];
    
    if(validDeviceParameterDataTypes){
        result = [validDeviceParameterDataTypes containsObject:[NSNumber numberWithInt:deviceParameterValueType]];
    }
        
    
    return result;
    
}

//TODO: check if int is valid as VSDevicePar
+(VSDeviceParameterDataype) deviceParameterDatatypeForString:(NSString*) stringName andError:(NSError**) error{
    NSNumber *foundValue = [deviceParameterTypeOfString objectForKey:stringName];
    
    if(foundValue){
        return [foundValue intValue];
    }
    else{
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ is not a name of a valid VSDeviceParameterDataype", stringName] code:0 userInfo:nil];
        return -1;
    }
}

+ (NSString *)stringForDeviceParameterDataType:(VSDeviceParameterDataype)dataType
{
    NSString *result = nil;
    
    for (NSString *string in [deviceParameterTypeOfString allKeys]) {
        if (dataType == [self deviceParameterDatatypeForString:string andError:nil]) {
            result = string;
        }
    }
    
    return result;
}

+ (VSDeviceParameterDataype) deviceParameterDatatypeForOSCParameterValueType:(OSCValueType) oscValueType{
    id dataType = [genericDeviceDataTypeForVSDeviceParameterDataype objectForKey:[NSNumber numberWithInt:oscValueType]];
    
    if(dataType && [dataType isKindOfClass:[NSNumber class]]){
        return [dataType intValue];
    }
    
    return -1;
}

+ (NSString *)nameForOSCType:(OSCValueType)type{
    
    NSString *string;
    
    switch (type) {
        case OSCValInt:     string = [NSString stringWithFormat:@"OSCValInt"];      break;
        case OSCValFloat:   string = [NSString stringWithFormat:@"OSCValFloat"];    break;
        case OSCValString:  string = [NSString stringWithFormat:@"OSCValString"];   break;
        case OSCValTimeTag: string = [NSString stringWithFormat:@"OSCValTimeTag"];  break;
        case OSCVal64Int:   string = [NSString stringWithFormat:@"OSCVal64Int"];    break;
        case OSCValDouble:  string = [NSString stringWithFormat:@"OSCValDouble"];   break;
        case OSCValChar:    string = [NSString stringWithFormat:@"OSCValChar"];     break;
        case OSCValColor:   string = [NSString stringWithFormat:@"OSCValColor"];    break;
        case OSCValMIDI:    string = [NSString stringWithFormat:@"OSCValMIDI"];     break;
        case OSCValBool:    string = [NSString stringWithFormat:@"OSCValBool"];     break;
        case OSCValNil:     string = [NSString stringWithFormat:@"OSCValNil"];      break;
        case OSCValInfinity:string = [NSString stringWithFormat:@"OSCValInfinity"]; break;
        case OSCValBlob:    string = [NSString stringWithFormat:@"OSCValBlob"];     break;
        default:            string = [NSString stringWithFormat:@"ERROR: OSCValueType not detected"]; break;
    }
        
    return string;
}

+ (BOOL)isDeviceParameterDatatypeSupportingRanges:(VSDeviceParameterDataype)dataType
{
    BOOL result = NO;
    
    if (dataType == VSDeviceParameterDataypeOSC64Int ||
        dataType == VSDeviceParameterDataypeOSCDouble ||
        dataType == VSDeviceParameterDataypeOSCFloat ||
        dataType == VSDeviceParameterDataypeOSCInt)
    {
        result = YES;
    }
    
    return result;
}

@end
