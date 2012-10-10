//
//  VSBaseAnimationCurve.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSAnimationCurve.h"
#import "VSCoreServices.h"

@implementation VSAnimationCurve
@synthesize strength = _strength;



- (id)init
{
    if (self = [super init]) {
        self.strength = 2.0;
        self.strengthRange = VSMakeRange(1.0, 10.0);
    }
    
    return self;
}

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    DDLogInfo(@"ERROR: This is the base class method which shouldn't be called");
    return 0.0f;
}

- (void)setStrength:(double)strength{
    _strength = strength;
}

- (double)strength{
    return _strength;
}

@end
