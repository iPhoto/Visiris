//
//  VSParameterTypeUtils.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameterXMLUtils.h"

#import "VSParameter.h"
#import "VSOptionParameter.h"

#import "VSCoreServices.h"

#define PARAMETER_XML_ATTRIBUTE_NAME @"name"
#define PARAMETER_XML_ATTRIBUTE_DATA_TYPE @"dataType"
#define PARAMETER_XML_ATTRIBUTE_DEFAULT_VALUE @"defaultValue"
#define PARAMETER_XML_ATTRIBUTE_TYPE @"type"
#define PARAMETER_XML_ATTRIBUTE_RANGE_FROM @"fromValue"
#define PARAMETER_XML_ATTRIBUTE_RANGE_TO @"toValue"
#define PARAMETER_XML_ATTRIBUTE_EDITABLE @"editable"
#define PARAMETER_XML_ATTRIBUTE_HIDDEN @"hidden"
#define PARAMETER_XML_OPTIONS_NODE @"options"
#define PARAMETER_XML_OPTION_NODE @"option"
#define PARAMETER_XML_ATTRIBUTE_OPTION_NAME @"name"

@implementation VSParameterXMLUtils

#pragma mark - Functions

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
    
    float minimumValue = 0;
    float maximumValue = 0;
    
    BOOL hasRange = NO;
    
    if([parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_FROM] && [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_TO]){
        maximumValue = [[[parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_TO] stringValue] floatValue];
        minimumValue = [[[parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_RANGE_FROM] stringValue] floatValue];
        
        hasRange = YES;
    }
    
    BOOL hidden = NO;
    BOOL editable = YES;
    
    if((tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_EDITABLE])){
        editable = [[tmpValue objectValue] boolValue];
    }
    
    if((tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_HIDDEN])){
        hidden = [[tmpValue objectValue] boolValue];
    }
    
    id defaultValue = nil;
    
    if((tmpValue = [parameterElement attributeForName:PARAMETER_XML_ATTRIBUTE_DEFAULT_VALUE])){
        switch (dataType) {
            case VSParameterDataTypeBool:
                defaultValue = [NSNumber numberWithBool:[[tmpValue objectValue] boolValue]];
                break;
            case VSParameterDataTypeString:
                defaultValue = [tmpValue stringValue];
                break;
            case VSParameterDataTypeFloat:
                defaultValue = [NSNumber numberWithFloat:[[tmpValue objectValue] floatValue]];
                break;
            default:
                break;
        }
    }
    
    
    if([[parameterElement elementsForName:PARAMETER_XML_OPTION_NODE] count]){
        VSOptionParameter *newOptionParameter = nil;
        if(hasRange){
            newOptionParameter = [[VSOptionParameter alloc] initWithName:name
                                                                   andID:orderNumber
                                                                  asType:type
                                                             forDataType:dataType
                                                        withDefaultValue:defaultValue
                                                             orderNumber:orderNumber
                                                                editable:editable
                                                                  hidden:hidden
                                                           rangeMinValue:minimumValue
                                                           rangeMaxValue:maximumValue];
        }
        else{
            newOptionParameter = [[VSOptionParameter alloc] initWithName:name
                                                                   andID:orderNumber
                                                                  asType:type
                                                             forDataType:dataType
                                                        withDefaultValue:defaultValue
                                                             orderNumber:orderNumber
                                                                editable:editable
                                                                  hidden:hidden];
        }
        
        
        for(NSXMLElement *element in [parameterElement elementsForName:PARAMETER_XML_OPTION_NODE]){
            
            NSString *key;
            id value;
            
            value = [element objectValue];
            
            if((tmpValue = [element attributeForName:PARAMETER_XML_ATTRIBUTE_OPTION_NAME])){
                key = [tmpValue stringValue];
            }
            
            if(key && value){
                [newOptionParameter addOptionWithKey:key forValue:value];
            }
        }
        
        return newOptionParameter;
    }
    else{
        
        if(hasRange){
            newParameter = [[VSParameter alloc] initWithName:name
                                                       andID:orderNumber
                                                      asType:type
                                                 forDataType:dataType
                                            withDefaultValue:defaultValue
                                                 orderNumber:orderNumber
                                                    editable:editable
                                                      hidden:hidden
                                               rangeMinValue:minimumValue
                                               rangeMaxValue:maximumValue];
        }
        else{
            newParameter = [[VSParameter alloc] initWithName:name
                                                       andID:orderNumber
                                                      asType:type
                                                 forDataType:dataType
                                            withDefaultValue:defaultValue
                                                 orderNumber:orderNumber
                                                    editable:editable
                                                      hidden:hidden];
        }
        
        return newParameter;
    }
    
    
    
    
}

#pragma mark - Private Functions

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

@end
