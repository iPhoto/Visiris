//
//  VSTrackViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSTrackView.h"

@class VSTrack;
@class VSTimelineObjectViewController;
@class VSTrackViewController;
@class VSProjectItemRepresentation;
@class VSTimelineObjectProxy;
@class VSTimelineObject;

#import "VSTimelineObjectViewController.h"
/**
 * Delegate Protocoll for TrackViewControllers
 */
@protocol VSTrackViewControllerDelegate <NSObject>

/** 
 * Called when a new ProjectItem was added to the TrackView
 * @param trackViewController VSTrackViewController of the VSTrackView the VSTimelineObject will be added to.
 * @param item VSProjectItemRepresentation the VSTimelineObject that will be added is based on
 * @param position NSPoint the VSTimelineObject to be added to
 * @param aWidth Width of he VSTimelineObject to be added to
 * @return The newly created TimelineObject if it was addedd successfully, NO otherwise
 */
-(VSTimelineObject*) trackViewController:(VSTrackViewController*) trackViewController addTimelineObjectBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item  atPosition:(NSPoint) position withWidth:(NSInteger) aWidth;

/** 
 * Called when an Object that can be added is over a track.
 * @param trackViewController VSTrackViewController of the VSTrackView the VSProjectItemRepresentation is over
 * @param item VSProjectItemRepresentation which is over the VSTrackView
 * @param position NSPoint the VSTimelineObjectProxy will be set for
 * @return The created VSTimelineObjectProxy if it was created successfully, nil otherwise
 */
-(VSTimelineObjectProxy*) trackViewController:(VSTrackViewController*) trackViewController createTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item atPosition:(NSPoint) position;

/**
 * Called before a timelineObjects gets selected
 * @param timelineObjectProxy VSTimelineObjectProxy that wants to be set selected
 * @param trackViewController VSTrackViewController the VSTimelineObjectView representing the timelineObjectProxy is subview of
 * @return YES if the VSTimelineObjectProxy is allowed to get selected, NO otherwise
 */
-(BOOL) timelineObjectProxy:(VSTimelineObjectProxy *) timelineObjectProxy willBeSelectedOnTrackViewController:(VSTrackViewController*) trackViewController;

/**
 * Called before a TimelineObject is removed from a track
 * @param timelineObjectProxy VSTimelineObjectProxy that will be removed.
 * @param trackViewController VSTrackViewController the timelineObjectProxy will be removed from
 */
-(void) timelineObjectProxy:(VSTimelineObjectProxy*) timelineObjectProxy willBeRemovedFromTrack:(VSTrackViewController*) trackViewController;

/**
 * Called when the view of the VSTrackViewController was clicked.
 * @param trackViewController VSTrackViewController of the view that was clicked
 */
-(void) didClickViewOfTrackViewController:(VSTrackViewController*) trackViewController;

@end



@interface VSTrackViewController : NSViewController<VSTrackViewDelegate, VSTimelineObjectControllerDelegate>

/** Track the view VSTrackViewController is responsible for */
@property VSTrack* track;

/** Delegate to called according to VSTrackViewControllerDelegate*/
@property id<VSTrackViewControllerDelegate> delegate;

/** Pixel Item Ratio as set in VSTimelineViewController */
@property double pixelTimeRatio;







/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView) for the given timeline.
 * @param track The VSTrack the VSTrackViewController represents
 * @return self
 */
-(id) initWithDefaultNibAccordingToTrack:(VSTrack*) track;

/** 
 * Called from VSTimelineViewController when the pixelTimeRatio has been changes 
 * @param newRatio The value the pixelItemRatio was changed to
 */
-(void) pixelTimeRatioDidChange:(double) newRatio;

@end
