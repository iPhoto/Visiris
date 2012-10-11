//
//  VSLinearAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSLinearAnimation.h"

@implementation VSLinearAnimation
@synthesize name    = _name;

- (id)init
{
    if (self = [super init]) {
        _name = @"Linear";
        self.hasStrength = NO;
    }
    
    return self;
}

+(void) load{
    [VSAnimationCurveFactory registerAnimationCurveOfClass:NSStringFromClass([self class])];
}

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue 
{
    double y, k, deltaY, deltaX, d, x;
    
    x = time - beginTime;
    
    d = startValue;
    
    deltaY = endValue - startValue;
    deltaX = endTime - beginTime;
    
    k = deltaY/deltaX;
    
    y = k * x + d;
        
    return y;
}

@end
