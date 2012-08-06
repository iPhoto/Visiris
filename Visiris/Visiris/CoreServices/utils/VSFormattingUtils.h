//
//  VSFormattingUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * Static Utility class for creating formatted string for different purposes.
*/
@interface VSFormattingUtils : NSObject


/**
 *  Creates a formated string (00:00:00) of the given milliseconds param
 *  @param milliseconds Value that will be formatted
 *  @param formatString Defines how the string is formatted. HH: hours, MM: minutes, SS: Seconds, TT: Tenths
 *  @result formated string (00:00:00) of the given milliseconds param
*/
+(NSString*) formatedTimeStringFromMilliseconds:(double)milliseconds formatString:(NSString*) formatString;

/**
 *  Creates a formated string (#,# KB, #,# MB) of the given bytes param
 *  @param bytes Value that will be formatted
 *  @result formated string (#,# KB, #,# MB) of the given bytes param
 */
+(NSString*) formatedFileSizeStringFromByteValue:(int) bytes;

@end
