//
//  VSEaseInBackAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSEaseInBackAnimation.h"

@implementation VSEaseInBackAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"EaseInBackInTESTING";
        self.hasStrength = NO;
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
//    end -= start;
//    value /= 1;
//    float s = 1.70158f;
//    return end * (value) * value * ((s + 1) * value - s) + start;

    
    double x, result;
    
    x = time - beginTime;
    
    x /= (endTime - beginTime);
        
    double s = 1.70158;
    
    x /= 1.0;
    
    endValue -= startValue;
    
    result = endValue * (x) * x * ((s + 1.0) * x - s) + startValue;
    
    return result;
}

@end
