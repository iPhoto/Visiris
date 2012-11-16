//
//  VSAnimationTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineViewController.h"
#import "VSAnimationCurvePopupViewController.h"

#import "VSAnimationTrackViewController.h"

@class VSAnimationTimelineScrollView;
@class VSTimelineObject;
@class VSPlayHead;
@class VSKeyFrame;
@class VSParameter;

/**
 * VSKeyFrameEditingDelegate-Protocoll defines how the VSAnimationTimelineViewController informs its delgates about selecting and editing of the VSKeyFrameViewController it shows on its tracks.
 */
@protocol VSKeyFrameEditingDelegate <NSObject>

/**
 * Called when the position of the Playhead is within the rect of on of the VSKeyFrameViews on the timeline. Neccessary to inform the delegate to set the specific VSKeyFrame as selected
 * @param keyFrame VSKeyFrame which is represented by the VSKeyFrameView the current position of the playhead is within its frame.
 * @param parameter VSParameter the VSKeyFrame belongs to
 */
-(void) playheadIsOverKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter;

/**
 * Called when the VSKeyFrameView responsible for the given VSKeyFrame was selected by the user, e.g. by clicking it.
 *
 * @param keyFrame VSKeyFrame which is represented by the VSKeyFrameView which wants to be selected
 * @param parameter VSParamter the VSKeyFrame which wants to be selected belongs to
 *
 * @return If YES the VSKeyFrameView representing the given VSKeyFrame is set selected.
 */
-(BOOL) wantToSelectKeyFrame:(VSKeyFrame*) keyFrame ofParamater:(VSParameter*) parameter;

-(BOOL) wantToUnselectKeyFrame:(VSKeyFrame*) keyFrame ofParamater:(VSParameter*) parameter;

/**
 * Called when the VSKeyFrameView representing the given VSKeyFrame is dragged around on its track
 *
 * @param keyFrame VSKeyFrame which is represented by the VSKeyFrameView which is dragged around
 * @param fromTimestamp Current timestamp of the VSKeyFrame
 * @param toTimestamp Timestamp the VSKeyFrame will be moved to. The timestamp is computed according to the VSKeyFrame's VSKeyFrameView frame.origin.x and the current pixelTimeRatio of the VSAnimationTrackViewController it belongs to. The timestamp can be altered by the delegate and it's value is recomputed to a pixel-position and used as the VSKeyFrameView's frame.origin.x
 * @param fromValue Current value of the given VSKeyFrame
 * @param toValue Value the given VSKeyFrame will be changed to. The value is computed according to the VSKeyFrame's VSKeyFrameView frame.origin.y and the range of the VSParameter the VSKeyFrame belongs to. The value can be altered by the delegate and it's recomputed to a pixel-position and used as the VSKeyFrameView's frame.origin.y
 *
 * @return Indicates wheter the VSKeyFrameView representing the given VSKeyFrame is allowed to be moved at all
 */
-(BOOL) keyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter willBeMovedFromTimestamp:(double) fromTimestamp toTimestamp:(double*) toTimestamp andFromValue:(id) fromValue toValue:(id*) toValue;

/**
 * Called when the user wants to delete the currently selected VSKeyFrames, e.g. by pressing Delete.
 *
 * @return Indicates wheter the selected keyFrames are allowed to be deleted or not
 */
-(BOOL) selectedKeyFramesWantsBeDeleted;

@end


/**
 * Subclass of VSTimelineView Controller holding the timeline where the user can animate the different VSParameter-Values of the currently selected VSTimelineObject
 *
 * VSAnimationTimelineViewController holds one VSAnimationTrack for every animateable for the currently selected VSTimelineObject and is responsible for communicating between its VSAnimationTracks and their content and the VSTimelineObjectParametersViewController.
 */
@interface VSAnimationTimelineViewController : VSTimelineViewController<VSAnimationTrackViewControllerDelegate, NSPopoverDelegate>

#pragma mark - Properties

/** Background-color of tracks with an odd index */
@property (strong) NSColor *oddTrackColor;

/** Background-color of tracks with an even index */
@property (strong) NSColor *evenTrackColor;

/** Delegate which is called as definend in VSKeyFrameEditingDelegate-Protocoll*/
@property (weak) id<VSKeyFrameEditingDelegate> keyFrameSelectingDelegate;

/** VSTimelineObject the animation-timeline is set up for */
@property (strong) VSTimelineObject*timelineObject;

/** Height of the VSAnimationTrackViews the VSAnimationTimelineViewController sets up for its VSTimelineObject */
@property float trackHeight;

@property (strong) IBOutlet VSAnimationCurvePopupViewController *animationCurvePopupViewController;
#pragma mark - Init

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSAnimationTimelineView) and the default-Height of its tracks
 *
 * @param trackHeight Defaul height of the timelines VSAnimationTrack's
 *
 * @return self
 */
-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight andMarginTop:(float) marginTop;

#pragma mark - Methods

/**
 * Creates an VSAnimationTrack for every animateable VSParameter of the given VSTimelineObject
 *
 * @param timelineObject For everey VSParameter of the given VSTimelineObject a VSAnimationTrack is added to the VSAnimationTimelineView
 */
-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject;

/**
 * Returns the VSAnimationTrackController representing the animation of the given paramter
 *
 * @param parameter VSParameter the representing VSAnimationTrackViewController is looked up for
 * 
 * @return The VSAnimationTrackViewController representing the animation of the given paramter if it was found, nil otherwise
 */
-(VSAnimationTrackViewController *) trackViewControllerOfParameter:(VSParameter *) parameter;

/**
 * Move's the playhead of the timeline to nearest keyFrame left of the current position of the playhed on then given parameter's VSAnimationTrackView
 *
 *@param parameter The nearest VSKeyFrame will be look up in the VSAnimationTrackViewController representing the given VSParameter.
 */
-(void) moveToNearestKeyFrameLeftOfParameter:(VSParameter*) parameter;

/**
 * Move's the playhead of the timeline to nearest keyFrame right of the current position of the playhed on then given parameter's VSAnimationTrackView
 *
 *@param parameter The nearest VSKeyFrame will be look up in the VSAnimationTrackViewController representing the given VSParameter.
 */
-(void) moveToNearestKeyFrameRightOfParameter:(VSParameter*) parameter;

/**
 * Removes all VSAnimationTrackViewControllers stored in animaitonTrackViewControllers
 */
-(void) resetTimeline;

/**
 * Sets the location of the playHeadMarker for playhead's currentTimePosition. Called when the VSTimelineObject the VSAnimationTimelineViewController represents was moved.
 */
-(void) updatePlayheadPosition;

@end
