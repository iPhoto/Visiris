//
//  VSSpringAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSSpringAnimation.h"

@implementation VSSpringAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"SpringTESTING";
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    double d, x, c, result;
    
    x = time - beginTime;

    x /= (endTime - beginTime);
    
    x = (sin(x * pi * (0.2 + 2.5 * x * x * x)) * pow(1.0 - x, 2.2) + x) * (1.0 + ( 1.2f * 1.0f * (1.0f - x)));
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    result = startValue + (endValue - startValue) * x;
    
    return result;
}

@end

