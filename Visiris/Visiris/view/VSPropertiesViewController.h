//
//  VSPropertiesViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Subclass of NSViewController responsible for displaying properties of VSProjectItem and VSTimelineObject.
 *
 * Listens on VSProjectItemRepresentationGotSelected, VSProjectItemRepresentationGotUnselected, VSTimelineObjectGotSelected, VSTimelineObjectsGotUnselected Notifications to be informed which object's properties to show.
 */
@interface VSPropertiesViewController : NSViewController

#pragma mark - Init 

-(id) initWithDefaultNib;

@end
