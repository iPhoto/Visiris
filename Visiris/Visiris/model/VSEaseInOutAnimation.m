//
//  VSEaseInOutAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSEaseInOutAnimation.h"

@implementation VSEaseInOutAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"EaseInOut";
        self.hasStrength = YES;
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue 
{
    double d, x, c, result;
    
    x = time - beginTime;
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    x /= (endTime - beginTime)/2.0;
    
    if (x < 1.0)
    {
        result = (c/2.0) * pow(x, self.strength) + d;
    }
    else
    {
        x -= 2;
        result = -(c/2.0) * (pow(fabs(x), self.strength) - 2) + d;
    }
    
    return result;
}

@end
