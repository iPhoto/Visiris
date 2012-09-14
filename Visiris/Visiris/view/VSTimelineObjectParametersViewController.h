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

@interface VSTimelineObjectParametersViewController : NSViewController<VSParameterViewKeyFrameDelegate>

@property NSArray *parameters;

@property VSTimelineObject *timelineObject;

@property float parameterViewHeight;

@property (weak) IBOutlet VSScrollView *scrollView;

@property NSColor *oddColor;

@property NSColor *evenColor;

-(id) initWithDefaultNibAndParameterViewHeight:(float) parameterViewHeight;

-(void) showParametersOfTimelineObject:(VSTimelineObject*) timelineObject;

/**
 * Removes all Parameter views
 */
-(void) resetParameters;

@end
