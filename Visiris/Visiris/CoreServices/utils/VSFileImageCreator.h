//
//  VSFileImageCreator.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Utility class to create Icons and Preview-Images for files.
 
 Uses the Quicklook Framework for creating the images. 
*/
@interface VSFileImageCreator : NSObject

/**
 Creates an preview image of the given file according to values set for the icon width and height in VSImageConstants
 @param file File the icon will be created for.
 @return Preview image of the given file according to the dimensions set in VSImageConstants, returns nil if no preview image was created.
*/
+(NSImage*) createIconForProjectItem:(NSString*) file;


/**
 Creates an preview image of the given file according to values set for the icon width and height in VSImageConstants
 @param file File the icon will be created for.
 @return Preview image of the given file according to the dimensions set in VSImageConstants, returns nil if no preview image was created.
 */
+(NSImage*) createIconForTimelineObject:(NSString*) file;


/**
 * Creates an Preview image for the given file in the given dimensions.
 * @param file File the icon will be created for.
 * @param width Width of the image
 * @param height Height of the image
 * @return Preview image of the given file according to the dimensions set in VSImageConstants, returns nil if no preview image was created.
 */
+(NSImage*) createImageForFile:(NSString*) file withWidht:(NSInteger) width withHeight:(NSInteger) height;
@end
