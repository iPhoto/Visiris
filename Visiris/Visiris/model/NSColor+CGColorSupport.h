//
//  NSColor+CGColorSupport.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

/**
 NSColor category for converting NSColor<-->CGColor
 */

@interface NSColor (GCColorSupport)
/**
 Return CGColor representation of the NSColor in the RGB color space
 */
@property (readonly) CGColorRef CGColor;
/**
 * Create new NSColor from a CGColorRef
 * @param aColor CGColorRef a NSColor will created for.
 * @retunr NSColor created corresponding the the given CGColorRef
 */
+ (NSColor*)colorWithCGColor:(CGColorRef)aColor;

- (CGColorRef)CGColor;

@end