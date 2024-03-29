//
//  VSNotificationConstants.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/** Name of the Notification sent when a VSProjectItemRepresentation got selected in VSProjectItemBrowserView */
extern NSString *VSProjectItemRepresentationGotSelected;

/** Name of the Notification sent when a VSProjectItemRepresentation got unselected in VSProjectItemBrowserView */
extern NSString *VSProjectItemRepresentationGotUnselected;

/** Name of the Notification sent when a VSTimelineObject got selected in VSTimelineView */
extern NSString *VSTimelineObjectsGotSelected;

/** Name of the Notification sent when a VSTimelineObject got unselected in VSTimelineView */
extern NSString *VSTimelineObjectsGotUnselected;

/** Name of the Notification sent when the VSTimelineObjectPropertiesView was hidden */
extern NSString *VSTimelineObjectPropertiesDidTurnInactive;

/** Name of the Notification sent when the key combination for starting the playback pressed */
extern NSString *VSPlayKeyWasPressed;

/** Key in the userInfo Dictionary of notifications holding the document it is sent from*/
extern NSString *VSSendersDocumentKeyInUserInfoDictionary;