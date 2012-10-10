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
@property (weak) IBOutlet NSSlider *strengthSlider;
@property (weak) VSAnimationCurve *currentlySelectedAnimationCurve;
@property (assign) float currentStrength;

-(void) showPopUpForAnimationCurves:(NSArray*) animationCurves andSelectAnimationCurve:(VSAnimationCurve*) selectedAnimationCurve;

- (IBAction)didChangeAnimationCurvesPopUpWindow:(NSPopUpButton *)sender;
- (IBAction)didChangeStrengthSlider:(NSSlider *)sender;

@end
