//
//  VSLayermode.h
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/12/12.
//
//

#import <Foundation/Foundation.h>

@interface VSLayermode : NSObject

/**
 * Given the Layermode as string returns the associating number (kind of enum)
 * @param string Layermode
 * @return Integer value of the Layermode
 */
+ (float)floatFromString:(NSString *)string;

@end
