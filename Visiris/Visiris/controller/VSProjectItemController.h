//
//  VSProjectItemController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSProjectItem;
@class VSProjectItemRepresentation;

/**
 * Manages the VSProjectItems-Objects
 * Singleton to manage all files added as ProjectItems to the Visirs-Project. Provides Functions to add and remove ProjectItems.
 */
@interface VSProjectItemController : NSObject



#pragma mark- Properties

/** Holds the projectItmes the controller is responsible */
@property (strong, readonly)    NSMutableArray  *projectItems;

#pragma Methods

/**
 * Creates a new ProjectItem for the given file and add. If a ProjectItem for that path does already exist, it isn't added twice.
 * @param filePath The path of the file that should be added as ProjectItem
 * @return YES if the file was added successfully to the list of ProjectItems or a projectItem for this file was already part of the ProjectItems, NO otherwise
*/
-(BOOL) addNewProjectItemFromFile:(NSString*) filePath;

/**
 * Creates a new ProjectItem for the given file and add. If a ProjectItem for that path does already exist, it isn't added twice.
 * @param filePath The path of the file that should be added as ProjectItem
 * @return The newly added VSProjectItme, if it was created successfully, nil otherwise 
 */
-(VSProjectItem*) addsAndReturnsNewProjectItemFromFile:(NSString*) filePath;

/**
 * Creates a new ProjectItem for the given file but doesn't add it to the projectItems array.
 * @param filePath The path of the file that should be added as ProjectItem
 * @return The newly created VSProjectItem if it was created successfully, nil otherwise
 */
-(VSProjectItem*) createNewProjectItemFromFile:(NSString*) filePath;

/**
 * Searches in the list of ProjectItems the controller manages for item defined by the given id
 * @param id ID of the ProjectItem to search for
 * @return A valid ProjectItem if one could be found for the given id, nil otherwise
*/
-(VSProjectItem*) projectItemWithID:(NSInteger) id;

/**
 * Creates a new ProjectItem based on given projectItemRepresentation
 */
-(VSProjectItem*) addNewProjectForRepresentation:(VSProjectItemRepresentation*) projectItemRepresentation;

@end
