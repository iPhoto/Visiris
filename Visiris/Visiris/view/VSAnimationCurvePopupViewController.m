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

-(void) showPopUpForAnimationCurves:(NSArray*) animationCurves{
    [self.aimationCurvesPopUpButton removeAllItems];
    
    self.animationCurves = animationCurves;
    
    
    for(VSAnimationCurve *animationCurve in self.animationCurves){
        [self.aimationCurvesPopUpButton insertItemWithTitle:animationCurve.name atIndex:[self.animationCurves indexOfObject:animationCurve]];
    }
}

- (IBAction)didChangeAnimationCurvesPopUpWindow:(NSPopUpButton *)sender {
    DDLogInfo(@"sel index: %d",[self.aimationCurvesPopUpButton indexOfSelectedItem]);
    self.currentlySelectedAnimationCurve = [self.animationCurves objectAtIndex:[self.aimationCurvesPopUpButton indexOfSelectedItem]];
    DDLogInfo(@"cur sel: %@",self.currentlySelectedAnimationCurve);
}
@end
