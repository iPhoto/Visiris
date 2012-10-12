//
//  VSOSCPort.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import "VSOSCPort.h"
#import "VSOSCAddress.h"

@implementation VSOSCPort


+ (VSOSCPort *)portWithPort:(unsigned int)port address:(VSOSCAddress *)address atTimestamp:(double)timestamp
{
    return [[VSOSCPort alloc] initWithPort:port address:address atTimestamp:timestamp];
}


- (id)initWithPort:(unsigned int)port address:(VSOSCAddress *)address atTimestamp:(double)timestamp
{
    self = [super init];
    if (self)
    {
        self.port = port;
        self.addresses = [NSMutableArray arrayWithObject:address];
        self.lastMessageReceivedTimestamp = timestamp;
    }
    
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Port: %d with addresses: %@", self.port, self.addresses];
}


- (void)addAddress:(VSOSCAddress *)address
{
    if (address) {
        [self.addresses addObject:address];
    }
}

@end
