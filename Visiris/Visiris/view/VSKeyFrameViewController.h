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

@protocol VSKeyFrameViewControllerDelegate <NSObject>

-(BOOL) keyFrameViewControllerWantsToBeSelected:(VSKeyFrameViewController*) keyFrameViewController;

-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController*) keyFrameViewController wantsToBeDraggeFrom:(NSPoint) fromPoint to:(NSPoint) toPoint;

-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *) keyFrameViewController;

@end

#import "VSViewMouseEventsDelegate.h"

@interface VSKeyFrameViewController : NSViewController<VSViewMouseEventsDelegate>

@property VSKeyFrame *keyFrame;
@property VSKeyFrameView *keyFrameView;
@property id<VSKeyFrameViewControllerDelegate> delegate;
@property BOOL selected;
@property double pixelTimeRatio;

- (id)initWithKeyFrame:(VSKeyFrame *)keyFrame withSize:(NSSize)size forPixelTimeRatio:(double)pixelTimeRatio andDelegate:(id<VSKeyFrameViewControllerDelegate>) delegate;


@end
