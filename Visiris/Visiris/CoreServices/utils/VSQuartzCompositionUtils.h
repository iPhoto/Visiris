//
//  VSQuartzCompositionReader.h
//  Visiris
//
//  Created by Scrat on 26/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Utility class thats read out information of a Quartz Composer Composition e.g. the Input Port Attributes 
 */
@interface VSQuartzCompositionUtils : NSObject

/**
 * Returns a NSDictionary containing the Input Port Attributes for Quartz Composer Composition at the given filePath. The key of the dictionary is the corresponding keys stored in attributes of the QCComposition initialized with the given filePath
 * @param filePath File path of Quartz Composer Composition the Input Ports are read out
 * @return A NSDictionary storing the Input Ports of the given Quartz Composer Composition. As keys are used the corresponding  keys stored in attributes of the QCComposition initialized with the given filePath. 
 */
+(NSDictionary*) publicInputPortsOfQuartzComposerPath:(NSString*) filePath;

/**
 * Reads out the corresponding VSParamterType for the given attributeKey.
 * @param attributeKey QCPortAttributeTypeKey of an Input Port Dictionary.
 * @return The corresponding VSParamterType to the given attributeKey if it was found, -1 otherwis
 */
+(int) visirisParameterDataTypeOfQCPortAttributeTypeKey:(NSString*) attributeKey;

@end
