//
//  VSEaseOutAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSEaseOutAnimation.h"

@implementation VSEaseOutAnimation

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue 
{
    double d, x, c;
    
    x = time - beginTime;
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    x /= endTime - beginTime;
    
    x--;
    
    return -c * (pow(fabs(x),self.strength) - 1) + d;
}

@end
