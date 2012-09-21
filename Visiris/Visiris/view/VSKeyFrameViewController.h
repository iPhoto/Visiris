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

@end

#import "VSViewMouseEventsDelegate.h"

@interface VSKeyFrameViewController : NSViewController<VSViewMouseEventsDelegate>

@property VSKeyFrame *keyFrame;
@property VSKeyFrameView *keyFrameView;
@property NSSize size;
@property double pixelTimeRatio;
@property id<VSKeyFrameViewControllerDelegate> delegate;
@property BOOL selected;

-(id) initWithKeyFrame:(VSKeyFrame*) keyFrame withSize:(NSSize) size forPixelTimeRatio:(double) pixelTimeRatio;


@end
