//
//  VSTimelineObjectSource.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VSProjectItem;

/**
 * Source a TimelineObjectRepresents
 */
@interface VSTimelineObjectSource : NSObject<NSCopying, NSCoding>

/** ProjectItem the source represents */
@property (strong) VSProjectItem* projectItem;

/** NSDictionary containing theparameters, the type - Property of VSParameter is used as Key. */
@property (strong) NSDictionary *parameters;


#pragma mark - Functions


-(id) initWithProjectItem:(VSProjectItem*) aProjectItem andParameters:(NSDictionary*) parameters;

/** 
 * Returns the name of the xml-File holding the definition of the source's parameter 
 * @return Resources-path of the xml-Files
 */
+(NSString *) parameterDefinitionXMLFileName;


#pragma mark - Methods

/**
 * Retursn the file path of the projectItem the timelineObject represents
 * @return file path of the projectItem the timelineObject represents
 */
-(NSString *) filePath;

/**
 * Retursn the duration of the projectItem the timelineObject represents
 * @return Duration of the projectItem the timelineObject represents
 */
-(double) fileDuration;

/**
 * Retursn the file size of the projectItem the timelineObject represents
 * @return File size of the projectItem the timelineObject represents
 */
-(float) fileSize;

/**
 * Returns the parameters of the VSTimelineObject as stored in its source having hidden set to NO.
 * @return The parameters of the VSTimelineObject as stored in its source having hidden set to NO. The type of the parameter is used as key
 */
-(NSArray *) visibleParameters;

@end
