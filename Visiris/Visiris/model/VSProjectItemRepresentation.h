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


-(id) initWithFile:(NSString *)file ofType:(VSFileType*) type name:(NSString *)name fileSize:(float)fileSize duration:(float)duration itemID:(NSInteger)itemID fileIcon:(NSImage*) icon;

#pragma mark - Methods


@end
