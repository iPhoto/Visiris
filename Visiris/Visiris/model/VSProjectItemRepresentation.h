//
//  VSProjectItemRepresentation.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSProjectItem.h"

/**
 * GUI-Representation of VSProjectItems
 *
 */
@interface VSProjectItemRepresentation : VSProjectItem<NSPasteboardWriting,NSPasteboardReading, NSCoding>

#pragma mark- Properties

/** Thumbnail of the file */
@property   (strong)    NSImage *icon;

/** Formated string of the fileSize in the format: 1,5 MB 0,45 KB*/
@property (readonly) NSString* fileSizeString;

/** Formated string of the duration in the format: hh:mm:ss */
@property (readonly) NSString* durationString;

#pragma mark- init

/**
 * Creates a  VSProjectItemRepresentation and inits it with the given parameters
 * @param file fileName of the file on the hard disk VSProjectItemRepresentation is ment to represent.
 * @param type Type of the represented file as VSFileType
 * @param name Name of VSProjectItemRepresentation.
 * @param fileSize of the file the  VSProjectItemRepresentation is ment to represent in bytes.
 * @param duration of the file the  VSProjectItemRepresentation is ment to represent in milliseconds.
 * @param itemID ID of the VSProjectItemRepresentation
 * @param icon Preview image of the file as an icon
 */
-(id) initWithFile:(NSString *)file ofType:(VSFileType*) type name:(NSString *)name fileSize:(float)fileSize duration:(float)duration itemID:(NSInteger)itemID fileIcon:(NSImage*) icon;

#pragma mark - Methods


@end
