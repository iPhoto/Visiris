//
//  VSCircularEaseIn.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSCircularEaseIn.h"

@implementation VSCircularEaseIn

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"CircularEaseInTESTING";
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
//	t /= d;
//	return -c * (Math.sqrt(1 - t*t) - 1) + b;
    
    double d, x, c, result;
    
    x = time - beginTime;
    
    x /= (endTime - beginTime);
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    result = -c * (sqrt(1 - x * x) - 1 ) + d;
    
    return result;
}

@end
