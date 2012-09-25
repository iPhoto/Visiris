//
//  VSAnimationTimelineViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSTimelineViewController.h"

#import "VSAnimationTrackViewController.h"

@class VSAnimationTimelineScrollView;
@class VSTimelineObject;
@class VSPlayHead;
@class VSKeyFrame;
@class VSParameter;

@protocol VSKeyFrameEditingDelegate <NSObject>

-(void) playheadIsOverKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) paramter;

-(BOOL) wantToSelectKeyFrame:(VSKeyFrame*) keyFrame ofParamater:(VSParameter*) parameter;

-(BOOL) keyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter willBeMovedFromTimestamp:(double) fromTimestamp toTimestamp:(double*) toTimestamp andFromValue:(id) fromValue toValue:(id*) toValue;

-(BOOL) selectedKeyFramesWantsBeDeleted;

@end



@interface VSAnimationTimelineViewController : VSTimelineViewController<VSAnimationTrackViewControllerDelegate>

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight;

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject;

-(VSAnimationTrackViewController *) trackViewControllerOfParameter:(VSParameter *) parameter;

-(void) moveToNearestKeyFrameLeftOfParameter:(VSParameter*) parameter;

-(void) moveToNearestKeyFrameRightOfParameter:(VSParameter*) parameter;

@property (weak) IBOutlet VSAnimationTimelineScrollView *scrollView;

@property NSColor *oddTrackColor;

@property NSColor *evenTrackColor;

@property VSPlayHead *playhead;

@property id<VSKeyFrameEditingDelegate> keyFrameSelectingDelegate;

@end
