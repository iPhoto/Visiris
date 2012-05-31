//
//  VSParameterTypeUtils.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameterXMLUtils.h"

#import "VSParameter.h"

#import "VSCoreServices.h"

#define PARAMETER_XML_ATTRIBUTE_NAME @"name"
#define PARAMETER_XML_ATTRIBUTE_DATA_TYPE @"dataType"
#define PARAMETER_XML_ATTRIBUTE_TYPE @"type"
#define PARAMETER_XML_ATTRIBUTE_RANGE_FROM @"fromValue"
#define PARAMETER_XML_ATTRIBUTE_RANGE_TO @"toValue"
#define PARAMETER_XML_ATTRIBUTE_EDITABLE @"editable"
#define PARAMETER_XML_ATTRIBUTE_HIDDEN @"hidden"

@implementation VSParameterXMLUtils

/**
 * Returns the VSParameterDataType for the given string
 * @param string String name of the data type
 * @return VSParameterDataType found for the given string, -1 if no VSParameterDataType was found
 */
+(VSParameterDataType) paramaterTypeOfString:(NSString*) string{
    if([[string lowercaseString] isEqualToString:@"float"]){
        return VSParameterDataTypeFloat;
    }
    
    if([[string lowercaseString] isEqualToString:@"bool"]){
        return VSParameterDataTypeBool;
    }
    
    if([[string lowercaseString] isEqualToString:@"string"]){
        return VSParameterDataTypeString;
    }
    
    return -1;
}

+(VSParameter*)parameterOfXMLNode:(NSXMLElement *)parameterElement atPosition:(NSInteger) orderNumber{
    VSParameter *newParameter;
    
    NSXMLNode *tmpValue;
    
    if(!(tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_NAME])){
        return nil;
    }
    
    NSString *name = [tmpValue stringValue];
    
    if(!(tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_DATA_TYPE])){
        return nil;
    }
    
    VSParameterDataType dataType =  [self paramaterTypeOfString:[tmpValue stringValue]];
    
    if(!(tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_TYPE])){
        return nil;
    }
    
    NSString *type = [tmpValue stringValue];
    
    NSRange range = NSMakeRange(0, 0);
    
    if([parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_FROM] && [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_TO]){
        float toValue = [[[parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_TO] stringValue] floatValue];
        float fromValue = [[[parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_FROM] stringValue] floatValue];
        
        range = NSMakeRange(fromValue, toValue-fromValue);
    }
    
    BOOL hidden = NO;
    BOOL editable = YES;
    
    if(!(tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_EDITABLE])){
        editable = [[tmpValue objectValue] boolValue];
    }
    
    if(!(tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_HIDDEN])){
        hidden = [[tmpValue objectValue] boolValue];
    }

    id defaultValue = nil;
    
    switch (dataType) {
        case VSParameterDataTypeBool:
            defaultValue = [NSNumber numberWithBool:[[parameterElement objectValue] boolValue]];
            break;
        case VSParameterDataTypeString:
            defaultValue = [[parameterElement objectValue] stringValue];
            break;   
        case VSParameterDataTypeFloat:
            defaultValue = [NSNumber numberWithFloat:[[parameterElement objectValue] floatValue]];
            break; 
        default:
            break;
    }

    if(range.length == 0 && range.location == 0){
        newParameter = [[VSParameter alloc] initWithName:name asType:type forDataType:dataType withDefaultValue:defaultValue orderNumber:orderNumber editable:editable hidden:hidden];
    }
    else {
        newParameter = [[VSParameter alloc] initWithName:name asType:type forDataType:dataType withDefaultValue:defaultValue orderNumber:orderNumber editable:editable hidden:hidden validRang:range];
    }
    
    
    
    return newParameter;
}


@end
