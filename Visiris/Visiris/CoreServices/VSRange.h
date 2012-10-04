//
//  VSRange.h
//  blubb
//
//  Created by Edwin Guggenbichler on 10/3/12.
//  Copyright (c) 2012 GraftInc. All rights reserved.
//

#include <Foundation/Foundation.h>


#ifndef blubb_VSRange_h
#define blubb_VSRange_h

/**
 * Simple Range using floats
 */
typedef struct{
    float min;
    float max;
} VSRange;

/**
 * Creates an VSRange with the given values
 */
NS_INLINE VSRange VSMakeRange(float min, float max){
    VSRange range;
    range.min = min;
    range.max = max;
    
    return range;
}

/**
 * Returns a string with the values of the given VSRange
 */
NS_INLINE NSString* NSStringFromVSRange(VSRange range){
    return [NSString stringWithFormat:@"(min: %f max %f)",range.min, range.max];
}


#endif
