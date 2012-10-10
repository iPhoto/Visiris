//
//  VSAnimationCurveFactory.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

#import <Foundation/Foundation.h>

@class VSAnimationCurve;

@interface VSAnimationCurveFactory : NSObject

+(void) registerAnimationCurveOfClass:(NSString*) classString;

+(NSDictionary*) registeredAnimationCurves;

+(VSAnimationCurve*) createAnimationCurveOfClass:(NSString*) classString;

@end
