//
//  VSOSCAddress.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/11/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInput.h"
#import "VSDeviceType.h"

@interface VSOSCInput : VSExternalInput

@property (assign) NSTimeInterval                           lastReceivedAddressTimestamp;
@property (strong) NSString                                 *address;
@property (assign) unsigned short                           port;
@property (assign) OSCValueType                             oscParameterType;

+ (VSOSCInput *)inputWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeInterval withPort:(unsigned short)port deviceType:(VSDeviceType)deviceType andParameterType:(OSCValueType)parameterType andValue:(id)value;

@end
