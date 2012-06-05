//
//  NSColor+CGColorSupport.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSColor+CGColorSupport.h"

@implementation NSColor (GCColorSupport)

- (CGColorRef)CGColor
{
    NSColor *colorRGB = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat components[4];
    [colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef theColor = CGColorCreate(theColorSpace, components);
    CGColorSpaceRelease(theColorSpace);
    CGColorRef returnColor = (__bridge CGColorRef)(__bridge id)theColor;
//    CGColorRelease(theColor);
    
    return returnColor;
}

+ (NSColor*)colorWithCGColor:(CGColorRef)aColor
{
    const CGFloat *components = CGColorGetComponents(aColor);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];
    return [self colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}
@end