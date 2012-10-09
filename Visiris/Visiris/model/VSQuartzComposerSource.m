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
        [self addPublicInputPortsToParameters];
    }
    
    return self;
}

/**
 * Adds the public input ports of the Quartz Composition the source is responsible for as a Dictionary of VSParamters to parameters at the key VSParameterQuartzComposerPublicInputs
 */
-(void) addPublicInputPortsToParameters{
    
    NSDictionary* publicInputs = [VSQuartzCompositionUtils publicInputPortsOfQuartzComposerPath:self.filePath];
    
    NSMutableDictionary *qcPublicInputParameters = [[NSMutableDictionary alloc]init];
    
    NSInteger i = self.parameters.count;
    
    //iterates through the entries
    for(id key in publicInputs){
        
        NSDictionary* publicInputDictionary = [publicInputs objectForKey:key];
        
        //reads out the VSParameterType corresponding to the QCPortAttributeTypeKey
        int parameterDataType = [VSQuartzCompositionUtils visirisParameterDataTypeOfQCPortAttributeTypeKey:[publicInputDictionary valueForKey:@"QCPortAttributeTypeKey"]];
        
        
        //if parameterDataType is -1 the inputPort is not valid for visirs
        if(parameterDataType !=-1){
            
            NSString *name = [NSString stringWithFormat:@"%@", [publicInputDictionary objectForKey:@"QCPortAttributeNameKey"]];;
            id defaultValue = [publicInputDictionary objectForKey:@"QCPortAttributeDefaultValueKey"];
            NSValue *maxValid = [publicInputDictionary objectForKey:@"QCPortAttributeMaximumValueKey"];
            NSValue *minValid = [publicInputDictionary objectForKey:@"QCPortAttributeMinimumValueKey"];
            
            bool hasRange = NO;
            
            float minimumValue = 0;
            float maximumValue = 0;
            
            if([minValid isKindOfClass:[NSNumber class]] && [maxValid isKindOfClass:[NSNumber class]]){
                minimumValue = [((NSNumber*) minValid) floatValue];
                maximumValue = [((NSNumber*) maxValid) floatValue];
                
                hasRange = YES;
            }
            
            VSParameter *newParameter = nil;
            
            if(hasRange){
                
                newParameter = [[VSParameter alloc] initWithName:name
                                                           andID:i
                                                          asType:name
                                                     forDataType:parameterDataType
                                                withDefaultValue:defaultValue
                                                     orderNumber:i
                                                        editable:YES
                                                          hidden:NO
                                                   rangeMinValue:minimumValue
                                                   rangeMaxValue:maximumValue];
            }
            else{
                newParameter = [[VSParameter alloc] initWithName:name
                                                           andID:i
                                                          asType:name
                                                     forDataType:parameterDataType
                                                withDefaultValue:defaultValue
                                                     orderNumber:i
                                                        editable:YES
                                                          hidden:NO];
            }
            
            if(newParameter){
                [qcPublicInputParameters setValue:newParameter forKey:key];
            }
        }
        
        i++;
        
    }
    
    //adds the VSParameters representing the Quartz Compositions's public Input Ports to the parameters Dictionary at the key VSParameterQuartzComposerPublicInputs
    if(qcPublicInputParameters.count){
        NSMutableDictionary *unionParameters = [NSMutableDictionary dictionaryWithDictionary:self.parameters];
        [unionParameters setObject:qcPublicInputParameters forKey:VSParameterQuartzComposerPublicInputs];
        
        self.parameters = [NSDictionary dictionaryWithDictionary:unionParameters];
    }
}

-(NSArray *) visibleParameters{
    
    NSMutableArray *visibleParameters = [NSMutableArray arrayWithArray:[super visibleParameters]];
    
    
    //Adds the VSParameters stored in as an NSDictionary in the parameters at the for the key VSParameterQuartzComposerPublicInputs to visibleParameters Array;
    
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
        
        [visibleParameters addObjectsFromArray:tmpArray];
        
        //sorts all paramter according to their order number
        visibleParameters = [NSMutableArray arrayWithArray:[visibleParameters sortedArrayUsingDescriptors:[NSMutableArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:NO]]]];
        
    }
    
    return visibleParameters;
    
}
@end
