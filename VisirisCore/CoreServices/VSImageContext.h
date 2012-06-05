//
//  VSImageContext.h
//  VisirisCore
//
//  Created by Scrat on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VSImageContext : NSObject

+ (CGContextRef)createARGBBitmapContext:(CGSize)contextSize;

@end
