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
@synthesize name        = _name;
@synthesize identifier = _identifier;

-(id) initWithName:(NSString *)name ofType:(VSDeviceParameterDataype)dataType identifier:(NSString *)identifier fromValue:(float)fromValue toValue:(float)toValue{
    if(self = [self initWithName:name ofType:dataType identifier:identifier]){
        self.range = VSMakeRange(fromValue, toValue);
        self.hasRange = YES;
    }
    
    return self;
}

-(id) initWithName:(NSString *)name ofType:(VSDeviceParameterDataype)dataType identifier:(NSString *)identifier{
    if(self = [super init]){
        _name = name;
        self.hasRange = NO;
        _identifier = identifier;
        _dataType = dataType;
    }
    
    return self;
}

#pragma mark - properties

-(float) currentFloatValue{
    if([self.currentValue respondsToSelector:@selector(floatValue)]){
        return [self.currentValue floatValue];
    }
    
    return 0.0;
}

-(BOOL) currentBOOLValue{
    if([self.currentValue respondsToSelector:@selector(boolValue)]){
        return [self.currentValue boolValue];
    }
    
    return false;
}

-(NSString*) currentStringValue{
    if([self.currentValue isKindOfClass:[NSString class]]){
        return self.currentValue;
    }
    
    if([self.currentValue respondsToSelector:@selector(stringValue)]){
        return [self.currentValue stringValue];
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

@end
