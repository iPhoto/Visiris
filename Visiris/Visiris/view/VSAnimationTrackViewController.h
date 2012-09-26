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

@end




/**
 * Represents the animation of one VSParameter
 *
 * Displays the animation's keyFrames and gives the user the possibilty to select, delete or move around the keyFrames
 */
@interface VSAnimationTrackViewController : NSViewController<VSViewResizingDelegate, VSKeyFrameViewControllerDelegate>

#pragma mark - Properties

/** The VSAnimationTrackViewController represents the animation of parameter*/
@property VSParameter *parameter;

/** Current pixelTimeRatio of the timeline the VSAnimationTrackViewController belongs to. Neccessary for positioning the keyframes right within the track */
@property double pixelTimeRatio;

/** Delgate the VSAnimationTrackViewController talks to as definend in VSAnimationTrackViewControllerDelegate-Protocoll */
@property id<VSAnimationTrackViewControllerDelegate> delegate;

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

-(void) reset;
-(VSKeyFrameViewController*) keyFrameViewControllerAtXPosition:(float) xPosition;
-(void) unselectAllKeyFrames;
-(float) parameterValueOfPixelPosition:(float) pixelValue forKeyFrame:(VSKeyFrameViewController *) keyFrameViewController;
-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *)keyFrameViewController;
-(void) removeSelectedKeyFrames;
-(VSKeyFrameViewController*) nearestKeyFrameViewRightOfXPosition:(float) xPosition;
-(VSKeyFrameViewController*) nearestKeyFrameViewLeftOfXPosition:(float) xPosition;
@end
