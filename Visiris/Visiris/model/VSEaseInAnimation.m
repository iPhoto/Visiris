//
//  VSEaseInAnimation.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import "VSEaseInAnimation.h"

@implementation VSEaseInAnimation

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue 
{
    double d, x, c;
    
    x = time - beginTime;
    
    d = startValue;
    
    //c change in value
    c = endValue - startValue;
    
    x /= endTime - beginTime;
    
    return c * pow(x,self.strength) + d;
}

@end
