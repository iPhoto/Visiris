//
//  VSSineAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSSineAnimation.h"

@implementation VSSineAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"SineTESTING";
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
    
    x /= endTime - beginTime;

//    result = c * cos(x * pi) + d;
    
    result = -c * cos(x * pi/2.0) + c + d;

    
    return result;
}

@end
