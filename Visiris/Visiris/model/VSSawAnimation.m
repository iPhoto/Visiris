//
//  VSSawAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import "VSSawAnimation.h"

@implementation VSSawAnimation

@synthesize name    = _name;

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (id)init
{
    if (self = [super init]) {
        _name = @"SawTESTING";
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    double y, k, deltaY, deltaX, d, x;
    
    int strength = (int)self.strength * 3;
    
    x = time - beginTime;
    
    d = startValue;
    
    deltaY = endValue - startValue;
    deltaX = endTime - beginTime;
    
    k = deltaY/deltaX;
    
    
    k *= strength;
    
    double normX = x / deltaX;
    
    
    
    rest = fmod(normX, strength);
    
    
    for (int i = 0; i < strength; i++)
    {
        if (i % 2 == 1)
        {
            y = k * x + d;
        }
        else
        {
            y = -k * x + endValue;
        }
        
    }
    
    
    
//    y = fmod(y,endValue);
    
    return y;

}


@end
