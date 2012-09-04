//
//  VSTimelineObjectParametersViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>


@interface VSTimelineObjectParametersViewController : NSViewController

-(id) initWithDefaultNibAndParameterViewHeight:(float) parameterViewHeight;

@property NSArray *parameters;

@property float parameterViewHeight;

-(void) showParameters:(NSArray*) parameters;

/**
 * Removes all Parameter views
 */
-(void) resetParameters;

@end
