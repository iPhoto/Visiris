//
//  NSString+VSOSCUniqueAddress.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/4/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (VSOSCUniqueAddress)

+ (NSString *)stringFromAddress:(NSString *)address atPort:(unsigned int)port;

@end
