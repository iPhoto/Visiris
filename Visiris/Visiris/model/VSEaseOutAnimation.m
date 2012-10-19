//
//  VSEaseOutAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSEaseOutAnimation.h"

@implementation VSEaseOutAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"EaseOu";
        self.hasStrength = YES;
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue 
{
    double d, x, c;
    
    x = time - beginTime;
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    x /= endTime - beginTime;
    
    x--;
    

    double result = -c * (pow(fabs(x),self.strength) - 1) + d;
    
    return result;
}

@end
