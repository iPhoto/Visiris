//
//  VSProjectItem.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@class VSFileType;


/**
 * Represents Files that can be dropped onto the timeline.
 *
 * Files the user has add do Visiris are stored as VSProject Item. All ProjectItems available in a Visiris Project are accessable through the VSProjectItemBrowser.
 */
@interface VSProjectItem : NSObject

/** Name of the ProjectItem, by default the file name without extension */
@property (strong) NSString* name;

/** File path of the file the ProjectItem represents. */
@property (strong) NSString* filePath;

/** Duration of the file the ProjectItem represents. For non-time-based files the duration stored in VSDefaultProjectItemDuration is used. */
@property double duration;

/** size of the represented file in bytes */
@property double fileSize;

/** Unique id of the item created by the controller*/
@property NSInteger itemID;

/** Type of the represented file as VSFileType */
@property (strong) VSFileType* fileType;

/**
 * Inits the VSProjectItem with the given values
 * @param file File path of the file the ProjectItem represents.
 * @param type Type of the represented file as VSFileType
 * @param name Name of the ProjectItem, by default the file name without extension
 * @param fileSize size of the represented file in bytes
 * @param duration Duration of the file the ProjectItem represents.
 * @param itemID Unique id of the item created by its controller
 */
 
-(id) initWithFile:(NSString*) file ofType:(VSFileType*) type name:(NSString*) name fileSize:(float) fileSize duration:(float) duration itemID:(NSInteger)itemID;

@end
