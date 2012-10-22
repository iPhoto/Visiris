//
//  VSOSCAddress.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/11/12.
//
//

#import "VSOSCInput.h"

@implementation VSOSCInput

@synthesize identifier = _identifier;
@synthesize parameterTypeName   = _parameterType;

+ (VSOSCInput *)inputWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeStamp withPort:(unsigned short)port deviceType:(VSDeviceType)deviceType andParameterType:(OSCValueType)parameterType
{
    return [[VSOSCInput alloc] initWithAddress:address timeStamp:timeStamp withPort:port deviceType:(VSDeviceType)deviceType andParameterType:parameterType];
}

- (id)initWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeStamp withPort:(unsigned short)port deviceType:(VSDeviceType)deviceType andParameterType:(OSCValueType)parameterType
{
    self = [super init];
    if (self) {
        self.address = address;
        self.lastReceivedAddressTimestamp = timeStamp;
        self.port = port;
        self.deviceType = deviceType;
        self.oscParameterType = parameterType;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"OSCAddress: %@ with timeStamp: %f", self.address, self.lastReceivedAddressTimestamp];
}

- (NSString *)identifier
{
    return [NSString stringFromAddress:self.address atPort:self.port];
}

- (NSString *)parameterTypeName
{
    return [VSDeviceParameterUtils nameForOSCType:self.oscParameterType];
}

- (NSString*) deviceTypeName{
    return @"not implemented yet";
}

-(VSDeviceParameterDataype) deviceParameterDataType{
    [VSDeviceParameterUtils deviceParameterDatatypeForOSCParameterValueType:self.oscParameterType];
}

@end
