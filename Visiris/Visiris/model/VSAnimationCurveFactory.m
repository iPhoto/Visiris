//
//  VSAnimationCurveFactory.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.10.12.
//
//

#import "VSAnimationCurveFactory.h"
#import "VSEaseInAnimation.h"
#import "VSAnimationCurve.h"

@implementation VSAnimationCurveFactory

static NSMutableDictionary *registeredAnimationCurves;


+(void) registerAnimationCurveOfClass:(NSString*) classString{
    
    if(!registeredAnimationCurves){
        registeredAnimationCurves= [[NSMutableDictionary alloc] init];
    }
    
    id animationCurveObjectToRegister = [[NSClassFromString(classString) alloc] init];
    
    if(animationCurveObjectToRegister && [animationCurveObjectToRegister isKindOfClass:[VSAnimationCurve class]]){
        [registeredAnimationCurves setObject:animationCurveObjectToRegister forKey:classString];
    }
}

+(VSAnimationCurve*) createAnimationCurveOfClass:(NSString*) classString{
    id animationCurve = [registeredAnimationCurves objectForKey:classString];
    
    if(animationCurve){
        return [[NSClassFromString(classString) alloc] init];
    }
    else{
        return nil;
    }
}

+(NSDictionary*) registeredAnimationCurves{
    return [NSDictionary dictionaryWithDictionary:registeredAnimationCurves];
}

@end
