//
//  VSAnimationCurvePopupViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

@class VSAnimationCurve;
@class VSKeyFrame;

#import <Cocoa/Cocoa.h>

@interface VSAnimationCurvePopupViewController : NSViewController

@property (weak) IBOutlet NSPopUpButton *aimationCurvesPopUpButton;
@property (weak) IBOutlet NSSlider *strengthSlider;
@property (weak) VSAnimationCurve *currentlySelectedAnimationCurve;
@property (assign) float currentStrength;

-(void) showAnimationCurveSelectionPopUpForKeyFrame:(VSKeyFrame*) selectedKeyFrame withAnimationCurves:(NSArray*) animationCurves;

- (IBAction)didChangeAnimationCurvesPopUpWindow:(NSPopUpButton *)sender;
- (IBAction)didChangeStrengthSlider:(NSSlider *)sender;

@end
