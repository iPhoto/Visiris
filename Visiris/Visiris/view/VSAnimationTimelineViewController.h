//
//  VSAnimationTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSTimelineViewController.h"

@class VSAnimationTimelineScrollView;
@class VSTimelineObject;
@class VSPlayHead;
@class VSKeyFrame;
@class VSParameter;

@protocol VSKeyFrameSelectingDelegate <NSObject>

-(void) playheadIsOverKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) paramter;

@end

@interface VSAnimationTimelineViewController : VSTimelineViewController

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight;

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject;

@property (weak) IBOutlet VSAnimationTimelineScrollView *scrollView;

@property NSColor *oddTrackColor;

@property NSColor *evenTrackColor;

@property VSPlayHead *playhead;

@property id<VSKeyFrameSelectingDelegate> keyFrameSelectingDelegate;

@end