//
//  VSTimelineObjectFactory.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSProjectItem;
@class VSTimelineObject;

/**
 * Factory for creating Timeline Objects
 *
 * The Timeline-Factory creates object of Subclasses of VSTimelineObjectSource. According to the VSFileType in the VSProjectItem Object the new TimelineObject is created for it decides which Class to create an new object of.
 */
@interface VSTimelineObjectFactory : NSObject

/**
 * Returns the shared instance of VSTimelineObjectFactory.
 * @return Singleton instance of VSTimelineObjectFactory
 */
+(VSTimelineObjectFactory *) sharedFactory;

/** Creates a new TimelineObject. 
 *
 *According to the VSFileType in the VSProjectItem Object the new TimelineObject is created for it decides which Class to create an new object of.
 @param projectItem ProjectItem the TimelineObject uses as source
 @return New TimelineObject if it was created successfully, nil otherwise.
 */
-(VSTimelineObject *)createTimelineObjectForProjectItem:(VSProjectItem*) projectItem;

/**
 * Creates a copy of the given VSTimelineObject and inits it with the given values
 * @param aStartTime Timeposition of the copy to be created on the timelien
 * @param aDuration Duration of the copy to be created on the timeline
 * @param Returns a copy of objectToCopy init with the given values if the copying was succesfully, nil otherwise
 */
-(VSTimelineObject*) createCopyOfTimelineObject:(VSTimelineObject*) objectToCopy atStartTime:(double) aStartTime withDuration:(double) aDuration;

@end
