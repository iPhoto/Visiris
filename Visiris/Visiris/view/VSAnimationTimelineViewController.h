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


@interface VSAnimationTimelineViewController : VSTimelineViewController

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNibAndTrackHeight:(float) trackHeight;

-(void) showTimelineForTimelineObject:(VSTimelineObject*) timelineObject;

@property (weak) IBOutlet VSAnimationTimelineScrollView *scrollView;

@end
