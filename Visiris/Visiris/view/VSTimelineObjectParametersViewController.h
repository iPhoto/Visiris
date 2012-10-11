//
//  VSTimelineObjectParametersViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSParameterViewController.h"

@class VSScrollView;
@class VSTimelineObject;

/**
 * Shows the parameters for given timelineObject
 */
@interface VSTimelineObjectParametersViewController : NSViewController

#pragma mark - Properties

/** The paramters stored in the timelineObject area displayed */
@property (weak) VSTimelineObject*timelineObject;

/** Height of the controller's view */
@property float parameterViewHeight;

/** ScrollView holding the parameters */
@property (weak) IBOutlet VSScrollView *scrollView;

/** Color for parameters with an odd index */
@property (strong) NSColor *oddColor;

/** Color for parameters with an even index */
@property (strong) NSColor *evenColor;

#pragma mark - Init

/**
 * Instantiates a VSTimelineObjectParametersViewController and set its parameterViewHeight
 *
 * @param parameterViewHeight Height the view VSTimelineObjectParametersViewController is responsible for is set to
 *
 * @return self;
 */
-(id) initWithDefaultNibAndParameterViewHeight:(float) parameterViewHeight;

#pragma mark - Methods

/**
 * Shows the neccessary controls for every VSParameter of the given timelineObejct
 *
 * Creates an VSParameterViewController for every parameter of the timelineObject inits them and adds them as subView of the VSTimelineObjectParametersViewController's scrollView
 *
 * @param timelineObject VSTimelineObject the parameters are displayed for
 * @param delegate VSParameterViewKeyFrameDelegate for newly created VSParameterViewController
 */
-(void) showParametersOfTimelineObject:(VSTimelineObject*) timelineObject connectedWithDelegate:(id<VSParameterViewKeyFrameDelegate>) delegate;

/**
 * Sets the VSKeyFrameViewController representing the given keyFrame of the given parameter as selected
 * @param keyFrame The VSKeyFrameViewController representing the keyFrame is set as selectd
 * @param parameter Parameter holindg the keyframe
 */
-(void) selectKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter;

/**
 * Sets the VSKeyFrameViewController representing the given keyFrame of the given parameter as unselected
 * @param keyFrame The VSKeyFrameViewController representing the keyFrame is set as selectd
 * @param parameter Parameter holindg the keyframe
 */
-(void) unselectKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter;

/**
 * Sets the selected-flag of all currently selected to NO
 */
-(void) unselectAllSelectedKeyFrames;

/**
 * Removes all Parameter views
 */
-(void) resetParameters;

@end
