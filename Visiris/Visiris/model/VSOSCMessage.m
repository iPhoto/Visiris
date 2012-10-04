//
//  VSOSCMessage.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import "VSOSCMessage.h"

@implementation VSOSCMessage

+ (id)messageWithValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port
{
    return [[VSOSCMessage alloc] initWithValue:value forAddress:address atPort:port];
}

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
