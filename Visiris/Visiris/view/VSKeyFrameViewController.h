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

@interface VSKeyFrameViewController : NSViewController

@property VSKeyFrame *keyFrame;
@property VSKeyFrameView *keyFrameView;
@property NSSize size;
@property double pixelTimeRatio;

-(id) initWithKeyFrame:(VSKeyFrame*) keyFrame withSize:(NSSize) size forPixelTimeRatio:(double) pixelTimeRatio;

@end
