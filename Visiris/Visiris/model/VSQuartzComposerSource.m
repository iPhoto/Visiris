//
//  VSQuartzComposerSource.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzComposerSource.h"

#import "VSParameter.h"

#import "VSCoreServices.h"

@implementation VSQuartzComposerSource

@synthesize projectItem = _projectItem;


+(NSString *) parameterDefinitionXMLFileName{
    return @"QuartzComposerSourceParameterDefinition";
}

-(id) initWithProjectItem:(VSProjectItem *)aProjectItem andParameters:(NSDictionary *)parameters{
    if(self = [super initWithProjectItem:aProjectItem andParameters:parameters]){
        [self addPublicInputsToParameters];
    }
    
    return self;
}

-(void) addPublicInputsToParameters{
    NSDictionary* publicInputs = [VSQuartzCompositionReader publicInputsOfQuartzComposerPath:self.filePath];
    NSMutableDictionary *qcPublicInputParameters = [[NSMutableDictionary alloc]init];
    
    int i = 0;
    
    for(id key in publicInputs){
        
        NSDictionary* publicInputDictionary = [publicInputs objectForKey:key];
        
        NSInteger parameterDataType = [VSQuartzCompositionReader visirisParameterDataTypeOfQCPortAttributeTypeKey:[publicInputDictionary valueForKey:@"QCPortAttributeTypeKey"]];
        
        if(parameterDataType !=-1){
            NSString *name = [NSString stringWithFormat:@"%@", [publicInputDictionary objectForKey:@"QCPortAttributeNameKey"]];;
            id defaultValue = [publicInputDictionary objectForKey:@"QCPortAttributeDefaultValueKey"];
            NSValue *maxValid = [publicInputDictionary objectForKey:@"QCPortAttributeMaximumValueKey"];
            NSValue *minValid = [publicInputDictionary objectForKey:@"QCPortAttributeMinimumValueKey"];
            
            float minimumValue = 0;
            float maximumValue = 0;
            
            if([minValid isKindOfClass:[NSNumber class]] && [maxValid isKindOfClass:[NSNumber class]]){
                minimumValue = [((NSNumber*) minValid) floatValue];
                maximumValue = [((NSNumber*) maxValid) floatValue];
            }
            
            VSParameter *newParameter = [[VSParameter alloc] initWithName:name asType:name forDataType:parameterDataType withDefaultValue:defaultValue orderNumber:i editable:YES hidden:NO rangeMinValue:minimumValue rangeMaxValue:maximumValue];
            
            if(newParameter){
                [qcPublicInputParameters setValue:newParameter forKey:key];
            }
        }
        
        i++;
        
    }
    
    if(qcPublicInputParameters.count){
        NSMutableDictionary *unionParameters = [NSMutableDictionary dictionaryWithDictionary:self.parameters];
        [unionParameters setObject:qcPublicInputParameters forKey:VSParameterQuartzComposerPublicInputs];
        
        self.parameters = [NSDictionary dictionaryWithDictionary:unionParameters];
    }
}

-(NSArray *) visibleParameters{
    
    NSMutableArray *visibleParameters = [NSMutableArray arrayWithArray:[super visibleParameters]];
    
    id result = [self.parameters objectForKey:VSParameterQuartzComposerPublicInputs];
    
    if(result && [result isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *qcParameters = (NSDictionary *) result;
        
        NSSet *set = [qcParameters keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
            if([obj isKindOfClass:[VSParameter class]]){
                if(!((VSParameter*) obj).hidden){
                    return YES;
                }
            }
            return NO;
        }];
        
        NSString *notFoundMarker = @"not found";
        
        NSArray *tmpArray = [qcParameters objectsForKeys:[set allObjects] notFoundMarker:notFoundMarker];
        tmpArray = [tmpArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:YES]]];
        
        [visibleParameters addObjectsFromArray:tmpArray];
        
    }
    
    return visibleParameters;
    
}
@end
