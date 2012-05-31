//
//  VSTimelineObjectProxy.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 14.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Representaiton of VSTimelineObjects
 */
@interface VSTimelineObjectProxy : NSObject

/** Timeposition of the Object on the timeline */
@property double startTime;

/** Duration of the object on the timeline */
@property double duration;

/** Name of the object, by defualt the same name as it's sourceObject */
@property NSString* name;

/** Thumbnail of the file */
@property NSImage* icon;

/** Indicates if object is selected or not */
@property BOOL selected;

#pragma mark- Init

-(id) initWithName:(NSString*) name atTime:(double) startTime duration:(double) duration icon:(NSImage*) icon;

@end
