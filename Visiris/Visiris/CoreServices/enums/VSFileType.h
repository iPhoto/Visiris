//
//  VSSupportedFile.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSCoreServices.h"

/**
 Files supported in Visirs are stored in VSFileType-Objects.
 
 Represents a file-type supported by Visirs. Holds its name, the fileType as UTI, the string of the class VSTimelineObjectFactory will create for a TimelineObject of this VSFileType. Additionaly the kind of the File
 
 */
@interface VSFileType : NSObject<NSCoding>

#pragma mark- Properties

/** Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... */
@property (strong) NSString* name;

/** Uniform Type Identifier of the file type. */
@property (strong) NSString* uti;

/** Name of the child-class of VSTimelineObejctSource associated with that fileType. The class is usually depending on the the fileKind. 
 */
@property (strong) NSString* timelineObjectSourceClassString;

/** Kind of the file like stored in the VSFileKind-Enum. E.g.: IMAGE, MOVIE, AUDIO, QUARTZ-COMPOSER. According to the fileKind the classString is set. */
@property (assign) VSFileKind fileKind;

/** Name of the child-class of VSSourceSupplier associated with that fileType. The class is usually depending on the the fileKind. 
 */
@property (strong) NSString* supplierClassString;

#pragma mark- Init

/*!
 Inits a new VSFileType with the given data.
 @param name Name of the VSFileType. Usually its extension. E.g. PNG, MOV,... 
 @param uti Uniform Type Identifier of the file type.
 @param kind Kind of the file like stored in the VSFileKind-Enum. E.g.: IMAGE, MOVIE, AUDIO, QUARTZ-COMPOSER. According to the fileKind the classString is set.
 @param timelineObjectSourceClassString Name of the child-class of VSTimelineObejctSource associated with that fileType. The class is usually depending on the the fileKind.
 @param supplierClassString Name of the child-class of VSSourceSupplier associated with that fileType. The class is usually depending on the the fileKind
*/
-(id) initWithName:(NSString*) name uti:(NSString*) uti ofKind:(VSFileKind) kind timelineObjectSourceClassString:(NSString*)timelineObjectSourceClassString supplierClassString:(NSString*) supplierClassString;

@end
