//
//  VSOSCMessage.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import "VSOSCMessage.h"

@implementation VSOSCMessage


#pragma mark - Public Class Methods

+ (id)messageWithValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port
{
    return [[VSOSCMessage alloc] initWithValue:value forAddress:address atPort:port];
}


#pragma mark - Private Init


/**
 * Creates and Returns a VSOSCMessage
 * @param value The Value can be NSNumber, NSString or NSBool
 * @param address The Address of the message
 * @param port The port the message is sent
 */
- (id)initWithValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port
{
    self = [super init];
    if (self) {
        self.port = port;
        self.address = address;
        self.value = value;
    }
    return self;
}

@end
