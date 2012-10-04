//
//  NSString+VSOSCUniqueAddress.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/4/12.
//
//

#import "NSString+VSOSCUniqueAddress.h"

@implementation NSString (VSOSCUniqueAddress)

+ (NSString *)stringFromAddress:(NSString *)address atPort:(unsigned int)port
{
    return [NSString stringWithFormat:@"%i-%@", port, address];
}

@end
