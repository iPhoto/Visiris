//
//  VSAnimationCurvePopupViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

@class VSAnimationCurve;

#import <Cocoa/Cocoa.h>

@interface VSAnimationCurvePopupViewController : NSViewController
@property (weak) IBOutlet NSPopUpButton *aimationCurvesPopUpButton;
- (IBAction)didChangeAnimationCurvesPopUpWindow:(NSPopUpButton *)sender;

-(void) showPopUpForAnimationCurves:(NSArray*) animationCurves;

@property VSAnimationCurve *currentlySelectedAnimationCurve;

@end
