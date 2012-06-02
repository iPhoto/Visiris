//
//  VSParameterTypeUtils.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSParameterDataType.h"

@class VSParameter;

/**
 * Utility class for parsing parameter description-files for the different kinds of VSTimelineObjects
 */
@interface VSParameterXMLUtils : NSObject

/**
 * Creates a new VSParameter-Object according to the data stored in the given XMLElement and sets its orderNumber with the given one.
 * @param parameterElement XMLElement holding the information for the VSParameter-Object
 * @param orderNumber Necessary that the VSParameter can be shown in the right order
 * @return VSParameter-Object if the given XMLElement was valid and the paramter was created successfully, nil otherwise
 */
+(VSParameter*) parameterOfXMLNode:(NSXMLElement*) parameterElement atPosition:(NSInteger) orderNumber;

@end