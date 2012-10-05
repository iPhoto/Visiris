//
//  VSDeviceParameter.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import "VSDeviceParameter.h"
#import "VSCoreServices.h"


@implementation VSDeviceParameter

-(id) initWithName:(NSString *)name oscPath:(NSString *)oscPath atPort:(NSUInteger) port fromValue:(float)fromValue toValue:(float)toValue{
    if(self = [self initWithName:name oscPath:oscPath atPort:port]){
        self.range = VSMakeRange(fromValue, toValue);
        self.hasRange = YES;
    }
    
    return self;
}

-(id) initWithName:(NSString *)name oscPath:(NSString *)oscPath atPort:(NSUInteger)port{
    if(self = [super init]){
        self.name = name;
        self.oscPath = oscPath;
        self.port = port;
        self.hasRange = NO;
    }
    
    return self;
}

#pragma mark - properties

-(float) currentFloatValue{
    if([self.currentValue isKindOfClass:[NSNumber class]]){
        return [self.currentValue floatValue];
    }
    
    return 0.0;
}

-(BOOL) currentBOOLValue{
    if([self.currentValue isKindOfClass:[NSNumber class]]){
        return [self.currentValue boolValue];
    }
    
    return false;
}

-(NSString*) currentStringValue{
    if([self.currentValue isKindOfClass:[NSString class]]){
        return self.currentValue;
    }
    
    return @"";
}

- (void)updateCurrentValue:(id)value
{
    DDLogInfo(@"CurrentValue: %f", [value floatValue]);
    self.currentValue = value;
}

- (NSInvocation *)invocationForNewValue
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(updateCurrentValue:)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(updateCurrentValue:)];
    
    return invocation;
}

@end
