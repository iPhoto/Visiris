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

@interface VSDeviceParameter : NSObject

-(id) initWithName:(NSString*) name ofType:(VSDeviceParameterDataype) dataType oscPath:(NSString*) oscPath atPort:(NSUInteger) port fromValue:(float) fromValue toValue:(float) toValue;

-(id) initWithName:(NSString*) name ofType:(VSDeviceParameterDataype) dataType oscPath:(NSString*) oscPath atPort:(NSUInteger) port;

@property (assign) BOOL hasRange;

@property (assign) VSRange range;

@property (strong) NSString *name;

@property (strong) NSString *oscPath;

@property (assign) NSUInteger port;

@property (strong) id currentValue;

@property (assign,readonly) float currentFloatValue;

@property (assign,readonly) BOOL currentBOOLValue;

@property (assign,readonly) NSString *currentStringValue;

@property (readonly) VSDeviceParameterDataype dataType;

- (NSInvocation *)invocationForNewValue;

@end
