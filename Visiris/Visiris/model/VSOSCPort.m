//
//  VSOSCPort.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import "VSOSCPort.h"

@implementation VSOSCPort


+ (VSOSCPort *)portWithPort:(unsigned int)port address:(NSString *)address atTimestamp:(double)timestamp
{
    return [[VSOSCPort alloc] initWithPort:port address:address atTimestamp:timestamp];
}


- (id)initWithPort:(unsigned int)port address:(NSString *)address atTimestamp:(double)timestamp
{
    self = [super init];
    if (self) {
        
        self.port = port;
        self.addresses = [NSMutableArray arrayWithObject:address];
        self.lastMessageReceivedTimestamp = timestamp;
    }
    
    return self;
}


- (void)addAddress:(NSString *)address
{
    if (address) {
        [self.addresses addObject:address];
    }
}

- (void)printDebugLog
{
    NSLog(@"===PRINT DEBUG LOG OSCPORT===");
    NSLog(@"addresses");
    for (NSString *address in self.addresses) {
        NSLog(@"Adress: %@", address);
    }
}

@end
