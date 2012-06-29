//
//  VSQuartzCompositionReader.m
//  Visiris
//
//  Created by Scrat on 26/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzCompositionUtils.h"
#import <Quartz/Quartz.h>

#import "VSCoreServices.h"


@interface VSQuartzCompositionUtils()


@end

@implementation VSQuartzCompositionUtils

/** Stores VSParameterType as value corresponding to the QCPortAttributeTypeKey used as key */
static NSDictionary *visirisParameterDataTypeForQCPortAttributeTypeKey;

+(void) initialize{
    visirisParameterDataTypeForQCPortAttributeTypeKey = 
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithInt:VSParameterDataTypeBool],QCPortTypeBoolean,
     [NSNumber numberWithInt:VSParameterDataTypeFloat],QCPortTypeNumber,
     [NSNumber numberWithInt:VSParameterDataTypeString],QCPortTypeString,
     [NSNumber numberWithInt:VSParameterDataTypeString],QCPortTypeIndex,
     nil];
}

+(NSMutableDictionary*) publicInputPortsOfQuartzComposerPath:(NSString*) filePath{
    
    NSMutableDictionary *publicInputs = [[NSMutableDictionary alloc] init];
    
    //checks if the given file path is valid
    if(filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        QCComposition *qcComposition = [QCComposition compositionWithFile:filePath];
        
        if(qcComposition){
            //iterates through the inputKeys
            for(id key in qcComposition.inputKeys){
                
                //stores the values for the key in the publicInput Dictionary
                id result = [qcComposition.attributes objectForKey:key];
                
                if(result){
                    [publicInputs setObject:result forKey:key];
                }
            }
        }
    }
    
    return publicInputs;
    
}

+(NSInteger) visirisParameterDataTypeOfQCPortAttributeTypeKey:(NSString*) attributeKey{
    id result = [visirisParameterDataTypeForQCPortAttributeTypeKey objectForKey:attributeKey];
    if (result) {
        return [result intValue];
    }
    return -1;
}

@end
