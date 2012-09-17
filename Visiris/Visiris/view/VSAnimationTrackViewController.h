//
//  VSAnimationTimelineTrackViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewResizingDelegate.h"

@class VSParameter;
@class VSKeyFrameViewController;

@interface VSAnimationTrackViewController : NSViewController<VSViewResizingDelegate>

@property VSParameter *parameter;
@property NSMutableArray *keyFrameViewControllers;
@property double pixelTimeRatio;

-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor forParameter:(VSParameter*) parameter andPixelTimeRatio:(double) pixelTimeRatio;
-(void) reset;
-(VSKeyFrameViewController*) keyFrameViewControllerAtXPosition:(float) xPosition;
@end
