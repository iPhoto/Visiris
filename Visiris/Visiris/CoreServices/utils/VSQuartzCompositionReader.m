//
//  VSQuartzCompositionReader.m
//  Visiris
//
//  Created by Scrat on 26/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzCompositionReader.h"
#import <Quartz/Quartz.h>

#import "VSCoreServices.h"


@interface VSQuartzCompositionReader()


@end

@implementation VSQuartzCompositionReader

static NSDictionary *visirisParameterDataTypeForQCPortAttributeTypeKey;

+(void) initialize{
    visirisParameterDataTypeForQCPortAttributeTypeKey = 
                        [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:VSParameterDataTypeBool],QCPortTypeBoolean,
                                        [NSNumber numberWithInt:VSParameterDataTypeFloat],QCPortTypeNumber,
                                        [NSNumber numberWithInt:VSParameterDataTypeString],QCPortTypeString, 
                         nil];
}

+(NSMutableDictionary*) publicInputsOfQuartzComposerPath:(NSString*) filePath{
    
    NSMutableDictionary *publicInputs = [[NSMutableDictionary alloc] init];
    
    if(filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        QCComposition *qcComposition = [QCComposition compositionWithFile:filePath];
        
        for(id key in qcComposition.inputKeys){
            
            id result = [qcComposition.attributes objectForKey:key];
            
            if(result){
                [publicInputs setObject:result forKey:key];
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
