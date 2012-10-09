//
//  VSDeviceParameter.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import "VSDeviceParameter.h"

#import "VSDeviceParameterUtils.h"

#import "VSCoreServices.h"


@implementation VSDeviceParameter

@synthesize dataType = _dataType;

-(id) initWithName:(NSString *)name ofType:(VSDeviceParameterDataype) dataType oscPath:(NSString *)oscPath atPort:(NSUInteger) port fromValue:(float)fromValue toValue:(float)toValue{
    if(self = [self initWithName:name ofType:dataType oscPath:oscPath atPort:port]){
        self.range = VSMakeRange(fromValue, toValue);
        self.hasRange = YES;
    }
    
    return self;
}

-(id) initWithName:(NSString *)name ofType:(VSDeviceParameterDataype) dataType oscPath:(NSString *)oscPath atPort:(NSUInteger)port{
    if(self = [super init]){
        self.name = name;
        self.oscPath = oscPath;
        self.port = port;
        self.hasRange = NO;
        _dataType = dataType;
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
    self.currentValue = value;
}

- (NSInvocation *)invocationForNewValue
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(updateCurrentValue:)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(updateCurrentValue:)];
    
    return invocation;
}

-(VSDeviceParameterDataype) dataType{
    DDLogInfo(@"get dtaType: %d",_dataType);
    return _dataType;
}

@end
