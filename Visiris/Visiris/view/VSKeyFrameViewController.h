//
//  VSKeyFrameViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import <Cocoa/Cocoa.h>

@class VSKeyFrame;
@class VSKeyFrameView;
@class VSKeyFrameViewController;

/**
 * Defines how VSKeyFrameViewController talks to its delegate
 */
@protocol VSKeyFrameViewControllerDelegate <NSObject>

/**
 * Called when the view the keyFrameViewController is responsible for want's to get selected
 * @param keyFrameViewController VSKeyFrameViewController responsibel for the view which wants to become selected
 * @return If YES the view of the given VSKeyFrameViewController is allowed to become selected.
 */
-(BOOL) keyFrameViewControllerWantsToBeSelected:(VSKeyFrameViewController*) keyFrameViewController;

/**
 * Called when the view the given VSKeyFrameViewController is responsible for is dragged.
 * @param fromPoint NSPoint describing the current frame-origin of VSKeyFrameViewController's view 
 * @param toPoint NSPoint describing the frame-origin the VSKeyFrameViewController's view wants to be set to
 * @return NSPoint the VSKeyFrameViewController's view'S frame-origin will be set to
 */
-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController*) keyFrameViewController wantsToBeDraggeFrom:(NSPoint) fromPoint to:(NSPoint) toPoint;

/**
 * Called when the VSKeyFrameViewController needs the pixel position according to the VSKeyFrame's value it's representing. Neccessary to position the view of the VSKeyFrameViewController on the y-Axis.
 * @param keyFrameViewController VSKeyFrameViewController holding the VSKeyFrame of which the value is computed to a pixelPosition
 * @return Pixel position corresponding to the value of the VSKeyFrame the VSKeyFrameViewController is representing
 */
-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *) keyFrameViewController;

-(void) keyFrameViewController:(VSKeyFrameViewController *) keyFrameViewController updatedPathToNextKeyFrame:(NSBezierPath*) pathToNextKeyFrame;

-(void) keyFrameViewController:(VSKeyFrameViewController *)keyFrameViewController didStopDragginAtPosition:(NSPoint)
finalPoint;

//-(BOOL) keyFrameViewControllerWantsToBeUnselected:(VSKeyFrameViewController *)keyFrameViewController;

@end

#import "VSViewMouseEventsDelegate.h"
#import "VSViewResizingDelegate.h"

/**
 * Representing a VSKeyFrame in the VSAnimationTimeline
 */
@interface VSKeyFrameViewController : NSViewController<VSViewMouseEventsDelegate, VSViewResizingDelegate>

/** VSKeyFrame the VSKeyFrameViewController is representing */
@property (weak) VSKeyFrame *keyFrame;

/** View of the VSKeyFrameViewController */
@property (strong) VSKeyFrameView *keyFrameView;

/** Delegate the VSKeyFrameViewControllerDelegate talks to as definend in VSKeyFrameViewControllerDelegate-Protocoll */
@property id<VSKeyFrameViewControllerDelegate> delegate;

/** Indicates wheter the VSKeyFrameViewControllerDelegate's keyFrame is currently selected or not */
@property BOOL selected;

/** PixelTimeRatio of the VSAnimationTimeline the VSKeyFrameViewControllerDelegate is part of. Neccessary to position the keyFrame right on the x-Axis. */
@property double pixelTimeRatio;

@property BOOL dragged;

@property (strong) NSBezierPath *pathToNextKeyFrameView;

@property (strong) VSKeyFrameViewController *nextKeyFrameViewController;

@property (strong) VSKeyFrameViewController *prevKeyFrameViewController;

/**
 * Inits the keyFrame with the given values
 * @param keyFrame VSKeyFrame the VSKeyFrameViewController represents
 * @param size Size of the view of VSKeyFrameViewController
 * @param pixelTimeRatio Current pixelTimeRatio the timeline the VSKeyFrameViewController is part of
 * @param delegate id<VSKeyFrameViewControllerDelegate> used as delegate according to VSKeyFrameViewControllerDelegate
 * @return self
 */
- (id)initWithKeyFrame:(VSKeyFrame *)keyFrame withSize:(NSSize)size forPixelTimeRatio:(double)pixelTimeRatio andDelegate:(id<VSKeyFrameViewControllerDelegate>) delegate;

-(void) updateConnectionPathToNextKeyFrame;

@end
