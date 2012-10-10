//
//  VSElasticEaseInAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSElasticEaseInAnimation.h"

@implementation VSElasticEaseInAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"ElasticEaseInTESTING";
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    double  x, result;
    
    x = time - beginTime;
    
    x /= (endTime - beginTime);
    
    endValue -= startValue;
    
    double d = 1.0f;
    float p = d * .3f;
    float s = 0;
    float a = 0;
    
    if (x == 0) return startValue;
    
    if ((x /= d) == 1) return startValue + endValue;
    
    if (a == 0 || a < fabs(endValue)){
        a = endValue;
        s = p / 4;
    }else{
        s = p / (2 * pi) * asin(endValue / a);
    }
    
    result = -(a * pow(2, 10 * (x-=1)) * sin((x * d - s) * (2 * pi) / p)) + startValue;

    return result;
}

@end
