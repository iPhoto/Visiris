//
//  VSBaseAnimationCurve.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import <Foundation/Foundation.h>

@interface VSBaseAnimationCurve : NSObject

@property (assign) double    strength;

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endVelue;

@end
