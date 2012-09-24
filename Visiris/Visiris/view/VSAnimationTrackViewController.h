//
//  VSAnimationTimelineTrackViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSViewResizingDelegate.h"
#import "VSKeyFrameViewController.h"

@class VSAnimationTrackViewController;

@protocol VSAnimationTrackViewControllerDelegate <NSObject>
    
-(BOOL) keyFrameViewController:(VSKeyFrameViewController *)keyFrameViewController wantsToBeSelectedOnTrack:(VSAnimationTrackViewController*) track;

-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController*) keyFrameViewController wantsToBeDraggedFrom:(NSPoint) fromPoint to:(NSPoint) toPoint onTrack:(VSAnimationTrackViewController*) track;

@end

@class VSParameter;

@interface VSAnimationTrackViewController : NSViewController<VSViewResizingDelegate, VSKeyFrameViewControllerDelegate>

@property VSParameter *parameter;
@property NSMutableArray *keyFrameViewControllers;
@property double pixelTimeRatio;
@property id<VSAnimationTrackViewControllerDelegate> delegate;

-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor forParameter:(VSParameter*) parameter andPixelTimeRatio:(double) pixelTimeRatio;
-(void) reset;
-(VSKeyFrameViewController*) keyFrameViewControllerAtXPosition:(float) xPosition;
-(void) unselectAllKeyFrames;
-(float) parameterValueOfPixelPosition:(float) pixelValue forKeyFrame:(VSKeyFrameViewController *) keyFrameViewController;
-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *)keyFrameViewController;
@end
