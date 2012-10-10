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
#import "VSKeyFrame.h"

#import "VSCoreServices.h"

@interface VSAnimationCurvePopupViewController ()
@property NSArray *animationCurves;
@property VSKeyFrame *keyFrame;
@end

@implementation VSAnimationCurvePopupViewController


@synthesize currentlySelectedAnimationCurve     = _currentlySelectedAnimationCurve;
@synthesize currentStrength                     = _currentStrength;

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

-(void) showAnimationCurveSelectionPopUpForKeyFrame:(VSKeyFrame *)selectedKeyFrame withAnimationCurves:(NSArray *)animationCurves{
    
    self.animationCurves = animationCurves;
    self.keyFrame = selectedKeyFrame;

    [self.aimationCurvesPopUpButton removeAllItems];
    
    for(VSAnimationCurve *animationCurve in self.animationCurves){
        [self.aimationCurvesPopUpButton insertItemWithTitle:animationCurve.name atIndex:[self.animationCurves indexOfObject:animationCurve]];
    }
    
    NSUInteger indexOfSelected = [self.animationCurves indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj class] == [self.keyFrame.animationCurve class]){
            return YES;
        }
        
        return NO;
    }];
    
    _currentlySelectedAnimationCurve = self.keyFrame.animationCurve;
    _currentStrength = self.keyFrame.animationCurve.strength;
    
    [self.aimationCurvesPopUpButton selectItemAtIndex:indexOfSelected];
}



-(void) changeKeyFramesAnimationCurve{
    if([self.currentlySelectedAnimationCurve class] == [self.keyFrame.animationCurve class]){
        self.keyFrame.animationCurve.strength = self.currentStrength;
    }
    else{
        VSAnimationCurve *animationCurve = [VSAnimationCurveFactory createAnimationCurveOfClass:NSStringFromClass([self.currentlySelectedAnimationCurve class])];
        
        if(animationCurve){
            animationCurve.strength = self.currentStrength;
            self.keyFrame.animationCurve =  animationCurve;
        }
        else{
            DDLogError(@" animationCurve is null");
        }
    }
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

-(void)setCurrentlySelectedAnimationCurve:(VSAnimationCurve *)currentlySelectedAnimationCurve{
    if(_currentlySelectedAnimationCurve != currentlySelectedAnimationCurve){
        _currentlySelectedAnimationCurve = currentlySelectedAnimationCurve;
        [self changeKeyFramesAnimationCurve];
    }
}

-(VSAnimationCurve*) currentlySelectedAnimationCurve{
    return _currentlySelectedAnimationCurve;
}

-(void) setCurrentStrength:(float)currentStrength{
    if(_currentStrength != currentStrength){
        _currentStrength = currentStrength;
        [self changeKeyFramesAnimationCurve];
    }
}

-(float) currentStrength{
    return _currentStrength;
}

@end
