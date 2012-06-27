//
//  VSQuartzCompositionReader.h
//  Visiris
//
//  Created by Scrat on 26/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSQuartzCompositionReader : NSObject

+(NSMutableDictionary*) publicInputsOfQuartzComposerPath:(NSString*) filePath;

+(NSInteger) visirisParameterDataTypeOfQCPortAttributeTypeKey:(NSString*) attributeKey;

@end
