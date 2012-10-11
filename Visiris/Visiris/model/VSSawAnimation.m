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
        self.hasStrength = YES;
    }
    
    return self;
}


- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue
{
    double y, k, deltaY, deltaX, d, x;
    
    int strength = (int)self.strength * 3;
    
    if (strength % 2 == 0) {
        strength--;
    }
    
    x = time - beginTime;
    
    d = startValue;
    
    deltaY = endValue - startValue;
    deltaX = endTime - beginTime;
    
    k = deltaY/deltaX;
    
    k *= strength;
    
    double normX = x / deltaX;
    
    double rest = fmod(normX, (1.0/(double)strength * 2.0));
    
    if (rest - 1.0/(double)strength > 0.0)
    {
        y = -k * x;
        
        y = fmod(y, deltaY);
        
        y += endValue;
    }
    else
    {
        y = k * x;
        
        y = fmod(y, deltaY);

        y += d;
    }
    
    return y;
}


@end
