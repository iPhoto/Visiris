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

NS_INLINE void VSRangeEncode(NSCoder *aCoder, VSRange range, NSString *key){
    [aCoder encodeObject:[NSData dataWithBytes:&range length:sizeof(range)] forKey:key];

}

NS_INLINE VSRange VSRangeDecode(NSCoder *aDecoder, NSString* key, NSError **error){
    NSData *data = [aDecoder decodeObjectForKey:key];
    
    if(data){
        VSRange range;


        [data getBytes:&range length:sizeof(range)];
        return range;
    }
    else{
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Object for %@ wasn't a valid NSValue",key]
                                    code:0
                                userInfo:nil];
        
        return VSMakeRange(0, 0);
    }
}


#endif
