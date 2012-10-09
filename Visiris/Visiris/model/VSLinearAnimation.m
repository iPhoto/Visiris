//
//  VSLinearAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSLinearAnimation.h"

@implementation VSLinearAnimation

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
