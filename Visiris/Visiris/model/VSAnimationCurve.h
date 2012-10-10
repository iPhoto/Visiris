//
//  VSBaseAnimationCurve.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/9/12.
//
//

#import <Foundation/Foundation.h>

#import "VSCoreServices.h"

#import "VSAnimationCurveFactory.h"

@interface VSAnimationCurve : NSObject

@property (assign) double    strength;

@property (strong, readonly) NSString *name;

@property (assign) VSRange strengthRange;

- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endVelue;

@end
