//
//  VSProjectItemRepresentationController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSProjectItemRepresentation;
@class VSProjectItem;

/**
 * Manages all ProjectItemRepresentations.
 *
 * The VSProjectItemRepresentationController creates a ProjectItemRepresentation for any VSProjectItem managed by the VSProjectItemController when it's initialized. It also observes VSProjectItemController on any changes on its VSProjectItems.
 */
@interface VSProjectItemRepresentationController : NSObject

/** Stores the representations for all VSProjectItmes in the project */
@property (strong, readonly) NSMutableArray  *projectItemRepresentations;

#pragma mark- Functions
/**
 * Returns the singleton Instance
 * @return Reference on the Singleton Instance
 */
+(VSProjectItemRepresentationController*)sharedManager;


#pragma mark- Methods

/**
 * Creates a new VSProjectItemRepresentation for the given ProjectItem but doesn't add it to the projectItemRepresentations-Array
 * @param projectItem VSProjectItem the representation will be created
 * @return The newly create VSProjectItemRepresentation if its creation was succesfully, nil otherwise.
 */
-(VSProjectItemRepresentation*) createPresentationOfProjectItem:(VSProjectItem*) projectItem;

/**
 * Creates a new VSProjectItemRepresentation for the given ProjectItem and adds it to the projectItemRepresentations-Array
 * @param projectItem VSProjectItem the representation will be created
 * @return YES if the VSProjectItemRepresentation was created succesfully, NO otherwise.
 */
-(BOOL) addNewRepresentationOfProjectItem:(VSProjectItem*) projectItem;


@end
