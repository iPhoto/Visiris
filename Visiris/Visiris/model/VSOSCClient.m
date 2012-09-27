//
//  VSOSCClient.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSOSCClient.h"
#import <VVOSC/VVOSC.h>

@interface VSOSCClient ()
{
}

@property (strong) OSCInPort                    *inPort;

@end

@implementation VSOSCClient

- (id)initWithOSCInPort:(OSCInPort *)oscInPort
{
    self = [super init];
    if (self) {
        _inPort = oscInPort;
        [_inPort setDelegate:self];
    }
    
    return self;
}

- (void)startObserving
{
    [_inPort start];
}


- (void)stopObserving
{
    [_inPort stop];
}

- (void)setPort:(unsigned short)port
{
    _port = port;
    [_inPort setPort:port];
}


#pragma mark - OSCInPort Delegate
- (void)receivedOSCMessage:(OSCMessage *)message
{
    NSLog(@"did received message: %@", message);
}


@end
