//
//  VSOSCClient.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSOSCClient.h"
#import <VVOSC/VVOSC.h>

#import "VSOSCPort.h"
#import "VSOSCMessage.h"

@interface VSOSCClient ()
{
    VSOSCClientType                             _type;
}

@property (strong) OSCInPort                    *inPort;

@end

@implementation VSOSCClient

- (id)initWithOSCInPort:(OSCInPort *)oscInPort andType:(VSOSCClientType)type
{
    self = [super init];
    if (self) {
    
        _inPort = oscInPort;
        [_inPort setDelegate:self];
        
        _type = type;
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

- (BOOL)isBinded
{
    return [_inPort bound];
}


#pragma mark - OSCInPort Delegate
- (void)receivedOSCMessage:(OSCMessage *)message
{
    switch (self.type) {
        case VSOSCClientActiveReceiver:
        {
            id newValue = [self valueForOSCValue:message.value];
            [self signalDelegateThatClientDidReceivedMessage:[VSOSCMessage messageWithValue:newValue forAddress:message.address atPort:self.port]];
        }
        break;
            
        case VSOSCClientPortSniffer:
        {
            [self signalDelegateThatClientDiscoveredActivePortWithAddress:message.address];
        }
        break;
            
        default:
            break;
    }
}


#pragma mark - Type Port Listener
- (void)signalDelegateThatClientDidReceivedMessage:(VSOSCMessage *)message
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(oscClient:didReceivedMessage:)]) {
            [self.delegate oscClient:self didReceivedMessage:message];
        }	
    }
}

- (void)signalDelegateThatClientDiscoveredActivePortWithAddress:(NSString *)address
{
    
    if (address) {
                
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(oscClient:didDiscoveredActivePort:)]) {
                [self.delegate oscClient:self didDiscoveredActivePort:[VSOSCPort portWithPort:_port address:address atTimestamp:[NSDate timeIntervalSinceReferenceDate]]];
            }
        }
    }
}


#pragma mark - Private Methods

- (VSOSCClientType)type
{
    return _type;
}

- (id)valueForOSCValue:(OSCValue *)oscValue
{
    id newValue;
    if (oscValue) {
        
        switch (oscValue.type) {
            case OSCValString:
                newValue = [oscValue stringValue];
                break;
                
            case OSCValFloat:
                newValue = [NSNumber numberWithFloat:[oscValue floatValue]];
                break;
                
            case OSCValBool:
                newValue = [NSNumber numberWithBool:[oscValue boolValue]];
                break;
                
            case OSCValInt:
                newValue = [NSNumber numberWithInt:[oscValue intValue]];
                break;
                
            default:
                break;
        }
    }
    
    return newValue;
}

@end
