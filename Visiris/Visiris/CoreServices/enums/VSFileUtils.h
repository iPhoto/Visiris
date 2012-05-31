//
//  VSFileUtils.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Utility class for dealing with files.
 *
 *  Reads out information of files e.g. the file size, its duration
*/
@interface VSFileUtils : NSObject

/**
 *  Returns the size of the given files in bytes.
 *  @param file The file the size should be read out.
 *  @return The size of the file, -1 if the file couldn't be found
*/
+(float) sizeOfFile:(NSString *)file;

/**
 * Reads out the duraiton of the file in milliseconds. Duration is only set for time-based files like Audio or Video.
 *  @param file the File the duration is tried to be read out.
 *  @return The duration of file or -1 if the duration couldn't be read out.
*/
+(float) durationInMillisecondsOfFile:(NSString*)file;
@end
