//
//  VSSupportedFilesManager.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VSFileType;


/*! Manages the  supported file types stored in VSFileType-Objects.
 * 
 * The static class VSSupportedFilesManager is responsible for managing the supported Files of Visiris. To add new fileType it has to be add to Initialize() method
 */
@interface VSSupportedFilesManager : NSObject

/** Checks if the type (UTI) of the given file is in the list of supported files.
 @param file File that will be checked if supported or not.   
 @return YES if the UTI of the given file was found in the list of supported files, NO otherwise.
*/
+(BOOL) supportsFile:(NSString*) file;

/** Searches for an entry in the supportedFiles list for the type of the given file.
 @param file File the type is looked up for.
 @return Returns the VSFileType that corresponds to the given file or nil if no VSFileType was found
*/
+(VSFileType*) typeOFile:(NSString*)file;

/** Dictionary of all supportedFiles. The UTI of the file is used as key
    @returns A dictionary holding all supportedFiles. The UTI of the file is used as key.
*/
+(NSDictionary*) supportedFiles;

@end
