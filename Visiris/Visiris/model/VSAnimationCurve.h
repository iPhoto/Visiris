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

/**
 * VSAnimationCurve is for creating specific Animations. This class is an baseclass which acts as an interface.
 */
@interface VSAnimationCurve : NSObject<NSCoding>

/** Strength is the intensity of an curve */
@property (assign) double strength;

/** The Name of the  curve  which is shown in the GUI*/
@property (strong, readonly) NSString *name;

/** Range of the strength */
@property (assign) VSRange strengthRange;

/** Does the curve has an Strength */
@property (assign) BOOL hasStrength;

/**
 * Calculating the final value
 * @param time The time the value should be calculated
 * @param beginTime The Time the animation starts
 * @param endTime The Time the animation ends
 * @param startValue The value at the beginning
 * @param endValue The value at the end of the animation
 * @return calculated value
 */
- (double)valueForTime:(double)time withBeginTime:(double)beginTime toEndTime:(double)endTime withStartValue:(double)startValue toEndValue:(double)endValue;

@end
