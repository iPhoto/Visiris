//
//  VSQuartzComposerSourceSupplier.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSQuartzComposerSourceSupplier.h"

#import "VSTimelineObject.h"
#import "VSTimelineObjectSource.h"
#import "VSParameter.h"
#import "VSAnimation.h"

#import "VSCoreServices.h"

@implementation VSQuartzComposerSourceSupplier


-(NSString*) getQuartzComposerPatchFilePath{
    return self.timelineObject.sourceObject.filePath;
}

- (NSDictionary *)getAtrributesForTimestamp:(double)aTimestamp{
    
    //adds the public input ports of the Quartz Composition the Supplier is responsible for to the attributes-dictionary
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[super getAtrributesForTimestamp:aTimestamp]];
    
    NSMutableDictionary *qcAttributes = [[NSMutableDictionary alloc] init];
    
    id result = [self.timelineObject.parameters objectForKey:VSParameterQuartzComposerPublicInputs];
    
    if([result isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *qcDictionary = (NSDictionary*) result;
        for(id key in qcDictionary){
            id value = [qcDictionary valueForKey:key];
            
            if([value isKindOfClass:[VSParameter class]]){
                [qcAttributes setValue:((VSParameter*) value).animation.defaultValue forKey:key];
            }
        }
        
        [attributes setObject:qcAttributes forKey:VSParameterQuartzComposerPublicInputs];
    }
    
    return attributes;
    
}

@end
