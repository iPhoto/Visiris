//
//  VSAnimationTimelineTrackViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSKeyFrameViewController.h"
#import "VSViewResizingDelegate.h"
#import "VSViewMouseEventsDelegate.h"

@class VSAnimationTrackViewController;
@class VSParameter;


/**
 * Defines how VSAnimationTrackViewController talks to its delegate if of the  VSKeyFrameViewController it is responsible for wants to get selected or to be dragged aournd
 */
@protocol VSAnimationTrackViewControllerDelegate <NSObject>

/**
 * Called when VSKeyFrameViewController the VSAnimationTrackViewController is responsible for wants to become selected
 *
 * @param keyFrameViewController VSKeyFrameViewController that wants to become selected
 * @param track VSAnimationTrackViewController responsible for the VSKeyFrameViewController that wants to become selected
 *
 * @return If YES the keyFrameViewController is becomes selected.
 */
-(BOOL) keyFrameViewController:(VSKeyFrameViewController *)keyFrameViewController wantsToBeSelectedOnTrack:(VSAnimationTrackViewController*) track;

/**
 * Called when VSKeyFrameViewController the VSAnimationTrackViewController is responsible for wants be dragged from the fromPoint to the toPoint
 *
 * @param keyFrameViewController VSKeyFrameViewController that wants to be moved
 * @param fromPoint Current frame.origin of keyFrameViewController's view
 * @param toPoint NSPoint the frame.origin of keyFrameViewController's view wants to be changed to
 * @param track VSAnimationTrackViewController responsible for the VSKeyFrameViewController that wants to be moved
 *
 * @return NSPoint the frame.origin of keyFrameViewController's view will be set to
 */
-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController*) keyFrameViewController wantsToBeDraggedFrom:(NSPoint) fromPoint to:(NSPoint) toPoint onTrack:(VSAnimationTrackViewController*) track;


-(void) didClickRightKeyFrameConnectionOfKeyFrameViewController:(VSKeyFrameViewController*) keyFrameViewController atPosition:(NSPoint) position onTrack:(VSAnimationTrackViewController*) animationTrackViewController;

-(BOOL) keyFrameViewController:(VSKeyFrameViewController *)keyFrameViewController wantsToBeUnselectedOnTrack:(VSAnimationTrackViewController*) track;

@end




/**
 * Represents the animation of one VSParameter
 *
 * Displays the animation's keyFrames and gives the user the possibilty to select, delete or move around the keyFrames
 */
@interface VSAnimationTrackViewController : NSViewController<VSViewResizingDelegate, VSKeyFrameViewControllerDelegate, VSViewMouseEventsDelegate>

#pragma mark - Properties

/** The VSAnimationTrackViewController represents the animation of parameter*/
@property (weak) VSParameter *parameter;

/** Current pixelTimeRatio of the timeline the VSAnimationTrackViewController belongs to. Neccessary for positioning the keyframes right within the track */
@property double pixelTimeRatio;

/** Delgate the VSAnimationTrackViewController talks to as definend in VSAnimationTrackViewControllerDelegate-Protocoll */
@property (weak) id<VSAnimationTrackViewControllerDelegate> delegate;



#pragma mark - Init

/**
 * Inits the VSAnimationTrackViewController and sets the given Values
 *
 * @param trackFrame Size and position of VSAnimationTrackViewController's view
 * @param trackColor Background-Color of the VSAnimationTrackViewController's view
 * @param parameter VSParameter the VSAnimationTrackViewController represents the animation of
 * @param pixelTimeRatio Current pixelTimeRatio of the timeline the VSAnimationTrackViewController belogns to
 *
 * @return self
 */
-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor forParameter:(VSParameter*) parameter andPixelTimeRatio:(double) pixelTimeRatio;

#pragma mark - Methods

/**
 * Finds out if any of the VSKeyFrameView the VSAnimationTrackViewController is responisble for is at the given xPosition.
 * 
 * If any keyFrame is ate the given position it is set as selected
 *
 * @param xPosition Funtion tries to find the VSKeyFrameView which is at the xPosition
 *
 * @return Returns the VSKeyFrameViewController responsible for the view which is at the given position if one is found, nil otherwise.
 */
-(VSKeyFrameViewController*) keyFrameViewControllerAtXPosition:(float) xPosition;

/**
 * Sets alle currently selected VSKeyFrameViewControllers as unselected
 */
-(void) unselectAllKeyFrames;

/**
 * Translates the given pixelPosition interpreted as origin.y of VSKeyFrameViewController's view to a value fitting the range of VSKeyFrameViewController's VSKeyFrame
 *
 * This funtion works for float-Values only
 *
 * @param pixelPosition Position interpret as origin.y of VSKeyFrameViewController's view.
 * @param keyFrameViewController VSKeyFrameViewController which is responsible for the VSKeyFrame holding the value
 *
 *@return The translated float-value if it was possible to transate it, the value stored in VSKeyFrameViewController's VSKeyFrame otherwise
 */
-(float) parameterValueOfPixelPosition:(float) pixelPosition forKeyFrame:(VSKeyFrameViewController *) keyFrameViewController;

/**
 * Translates the value of keyFrameViewController's VSKeyFrame to a pixel position representing origin.y of the view's frame.
 *
 * @param keyFrameViewController VSKeyFrameViewController representing the VSKeyFrame which's value is be translated.
 * 
 * @return Pixel Position if the translation was successfull, the midpoint.y of keyFrameViewController' view otherwise
 */
-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *)keyFrameViewController;

/**
 * Removes the currently selected keyFrames of the track
 */
-(void) removeSelectedKeyFrames;

/**
 * Iterates through all VSKeyFrameViewController of the track and finds out which is the nearest to the given xPosition
 *
 * @param xPosition Position where is search from to the right
 *
 * @return VSKeyFrameViewController if one was right of the position, nil otherwise
 */
-(VSKeyFrameViewController*) nearestKeyFrameViewRightOfXPosition:(float) xPosition;

/**
 * Iterates through all VSKeyFrameViewController of the track and finds out which is the nearest to the given xPosition
 *
 * @param xPosition Position where is search from to the left
 *
 * @return VSKeyFrameViewController if one was left of the position, nil otherwise
 */
-(VSKeyFrameViewController*) nearestKeyFrameViewLeftOfXPosition:(float) xPosition;
@end
