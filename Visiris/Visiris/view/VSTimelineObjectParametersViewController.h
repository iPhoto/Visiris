//
//  VSTimelineObjectParametersViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>

@class VSScrollView;

@interface VSTimelineObjectParametersViewController : NSViewController

@property NSArray *parameters;

@property float parameterViewHeight;

@property (weak) IBOutlet VSScrollView *scrollView;

@property NSColor *oddColor;

@property NSColor *evenColor;

-(id) initWithDefaultNibAndParameterViewHeight:(float) parameterViewHeight;

-(void) showParameters:(NSArray*) parameters;

/**
 * Removes all Parameter views
 */
-(void) resetParameters;

@end
