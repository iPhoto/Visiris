//
//  VSDeviceParameter.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import <Foundation/Foundation.h>

#import "VSDeviceParameterUtils.h"

#import "VSCoreServices.h"



extern float const SMOOTHINGRANGEMINPRESENTATION;
extern float const SMOOTHINGRANGEMAXPRESENTATION;

@interface VSDeviceParameter : NSObject

-(id) initWithName:(NSString*) name ofType:(VSDeviceParameterDataype) dataType identifier:(NSString*) identifier  fromValue:(float) fromValue toValue:(float) toValue;

-(id) initWithName:(NSString*) name ofType:(VSDeviceParameterDataype) dataType identifier:(NSString*) identifier;

@property (assign) BOOL hasRange;

@property (assign) VSRange range;

@property (strong, readonly) NSString *name;

@property (strong, readonly) NSString *identifier;

@property (strong) id currentValue;

@property (assign,readonly) float currentFloatValue;

@property (assign,readonly) BOOL currentBOOLValue;

@property (assign,readonly) NSString *currentStringValue;

@property (readonly) VSDeviceParameterDataype dataType;



- (NSInvocation *)invocationForNewValue;

- (VSRange)smoothingRange;

@end
