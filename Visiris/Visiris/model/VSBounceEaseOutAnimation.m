//
//  VSBounceEaseOutAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSBounceEaseOutAnimation.h"

@implementation VSBounceEaseOutAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"BounceEaseOutTESTING";
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    double x, result;
    
    x = time - beginTime;
    
    x /= (endTime - beginTime);
    
    x /= 1.0;
    endValue -= startValue;
    if (x < (1 / 2.75f)){
        result = endValue * (7.5625f * x * x) + startValue;
    }else if (x < (2 / 2.75f)){
        x -= (1.5f / 2.75f);
        result = endValue * (7.5625f * (x) * x + .75f) + startValue;
    }else if (x < (2.5 / 2.75)){
        x -= (2.25f / 2.75f);
        result = endValue * (7.5625f * (x) * x + .9375f) + startValue;
    }else{
        x -= (2.625f / 2.75f);
        result = endValue * (7.5625f * (x) * x + .984375f) + startValue;
    }

    return result;
}

@end
