//
//  VSDeviceParameter.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import <Foundation/Foundation.h>

@interface VSDeviceParameter : NSObject

-(id) initWithName:(NSString*) name oscPath:(NSString*) oscPath atPort:(NSUInteger) port fromValue:(float) fromValue toValue:(float) toValue;

@property (assign) NSRange deviceValueMappingRange;

@property (strong) NSString *name;

@property (strong) NSString *oscPath;

@property (assign) NSUInteger port;

@property (strong) id currentValue;

@property (assign,readonly) float currentFloatValue;

@property (assign,readonly) BOOL currentBOOLValue;

@property (assign,readonly) NSString *currentStringValue;

- (NSInvocation *)invocationForNewValue;

@end
