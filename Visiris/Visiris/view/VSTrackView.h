//
//  VSTrackView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTrackView;

/**
 * Delegate for ViewTracks
 */
@protocol VSTrackViewDelegate <NSObject>

/**
 * Called when objects have been dropped on a VSTrackView during a drag'n'drop-Operation
 * @param trackView The VSTrackView the objects has been dropped
 * @param draggingInfo NSDraggingInfo of the drag'n'drop-Operation
 * @param Position relative to trackView where the objects have been dropped
 * @return YES if the dropped objects were handled succesfully, NO otherwise
 */
-(BOOL) trackView:(VSTrackView*) trackView objectsHaveBeenDropped:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint) position;

/**
 * Called when objects have entered the VSTrackView during a drag'n'drop-Operation
 * @param trackView The VSTrackView the objects have entered
 * @param draggingInfo NSDraggingInfo of the drag'n'drop-Operation
 * @param Position relative to trackView where the objects have entered
 * @return A NSDragOperation according to the data stored in draggingInfo
 */
-(NSDragOperation) trackView:(VSTrackView*) trackView objectsHaveEntered:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint) position;

/**
 * Called when objects have exited the VSTrackView during a drag'n'drop-Operation
 * @param trackView The VSTrackView the objects have exited
 * @param draggingInfo NSDraggingInfo of the drag'n'drop-Operation
 * @return YES if the objects were handled succesfully, NO otherwise
 */
-(BOOL) trackView:(VSTrackView*) trackView objectHaveExited:(id<NSDraggingInfo>)draggingInfo;


/**
 * Called when objects are over the VSTrackView during a drag'n'drop-Operation and the mouse-position has changed
 * @param trackView The VSTrackView the objects are over
 * @param draggingInfo NSDraggingInfo of the drag'n'drop-Operation
 * @param Position relative to trackView where the objects are currently positioned
 * @return YES if the objects were handled succesfully, NO otherwise
 */
-(void) trackView:(VSTrackView*) trackView objectsOverTrack:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint) position;

/**
 * Called when mouseDown event of VSTrackView is called
 * @param trackView VSTrackView which was clicked
 */
-(void) didClicktrackView:(VSTrackView *)trackView;

@end



@class VSTimelineObjectViewController;

/**
 * VSTrackView displays a VSTrack.
 *
 * VSTrackView is valid dragging destinaiton for VSProjectItems and files, as long as they are supported by Visirs. It manages its VSTimelineObjectsViews and informs it controller about newly added objects as defined in  VSTrackViewDelegate protocoll
 */
@interface VSTrackView : NSView<NSDraggingDestination>

/** Delegate that is informed about objects added to the the VSTrackView as defined in  VSTrackViewDelegate protocoll*/
@property id<VSTrackViewDelegate> controllerDelegate;


@end
