//
//  VSExponentialEaseIn.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSExponentialEaseIn.h"

@implementation VSExponentialEaseIn

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"ExponentialEaseInTESTING";
        self.hasStrength = NO;
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    //    	return c * Math.pow( 2, 10 * (t/d - 1) ) + b;

    double d, x, c, result;
    
    x = time - beginTime;
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    result = c * pow(2,10 * (x/(endTime-beginTime)-1.0)) + d;
    
    return result;
}


@end
