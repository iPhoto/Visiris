//
//  VSAnimationCurvePopupViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

#import "VSAnimationCurvePopupViewController.h"

#import "VSAnimationCurve.h"
#import "VSAnimationCurveFactory.h"

#import "VSCoreServices.h"

@interface VSAnimationCurvePopupViewController ()
@property NSArray *animationCurves;
@end

@implementation VSAnimationCurvePopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    
}

-(void) showPopUpForAnimationCurves:(NSArray*) animationCurves andSelectAnimationCurve:(VSAnimationCurve*) selectedAnimationCurve{
    [self.aimationCurvesPopUpButton removeAllItems];
    
    self.animationCurves = animationCurves;
    

    for(VSAnimationCurve *animationCurve in self.animationCurves){
        [self.aimationCurvesPopUpButton insertItemWithTitle:animationCurve.name atIndex:[self.animationCurves indexOfObject:animationCurve]];
    }
    
    NSUInteger indexOfSelected = [self.animationCurves indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj class] == [selectedAnimationCurve class]){
            return YES;
        }
        
        return NO;
    }];
    
    [self.aimationCurvesPopUpButton selectItemAtIndex:indexOfSelected];
    
    self.currentStrength = selectedAnimationCurve.strength;
    
    self.currentlySelectedAnimationCurve = selectedAnimationCurve;

}

- (IBAction)didChangeAnimationCurvesPopUpWindow:(NSPopUpButton *)sender {
    self.currentlySelectedAnimationCurve = [self.animationCurves objectAtIndex:[self.aimationCurvesPopUpButton indexOfSelectedItem]];
    
    [self.strengthSlider setMinValue:self.currentlySelectedAnimationCurve.strengthRange.min];
    [self.strengthSlider setMaxValue:self.currentlySelectedAnimationCurve.strengthRange.max];
    
    [self.strengthSlider setFloatValue:self.currentStrength];
}

- (IBAction)didChangeStrengthSlider:(NSSlider *)sender {
    self.currentStrength = [sender floatValue];
}
@end
