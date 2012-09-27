//
//  VSOSCInputManager.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <VVOSC/VVOSC.h>
#import "VSOSCInputManager.h"
#import "VSOSCClient.h"

#import "VSCoreServices.h"


#define kVSOSCInputManager_inputRangeStart @"kVSOSCInputManager_inputRangeStart"
#define kVSOSCInputManager_inputRangeEnd @"kVSOSCInputManager_inputRangeEnd"

@interface VSOSCInputManager ()
{
    NSRange                                             _observablePorts;
    
    NSTimer                                             *_portObserverTimer;
    
    OSCManager                                          *_oscManager;
    
    NSUInteger                                          _lastPort;
    NSUInteger                                          _numberOfInputClients;
    
}

@property (strong) NSMutableArray                       *availableInputPorts;


@end

@implementation VSOSCInputManager

+ (NSString *)identifier
{
    return kVSInputManager_OSC;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _oscManager = [[OSCManager alloc] init];
        
        _observablePorts = NSMakeRange(1234, 5000);
        
        /* TODO: Implement Preference Panel
        observablePorts.location = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeStart];
        observablePorts.length = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeEnd];
        */
        
        _lastPort = _observablePorts.location;
        _numberOfInputClients = 10;
        
        
        self.availableInputPorts = [[NSMutableArray alloc] initWithCapacity:_numberOfInputClients];
        [self createInputObserver:NSMakeRange(_observablePorts.location, _observablePorts.location+_numberOfInputClients)];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", kVSInputManager_OSC];
}

#pragma mark - VSExternalInputProtocol implementation
- (void)createInputObserver:(NSRange)rangeOfInputPorts
{
    NSUInteger currentPortOffset = 0;
    for (NSInteger i = rangeOfInputPorts.location; i < rangeOfInputPorts.length; i++) {
        
        NSUInteger portToListen = rangeOfInputPorts.location + currentPortOffset; //(int)(rangeOfInputPorts.location+i);
        _lastPort = portToListen;
        OSCInPort *inPort = [_oscManager createNewInputForPort:(int)portToListen];
        if (inPort) {
            [inPort stop];
            VSOSCClient *client = [[VSOSCClient alloc] initWithOSCInPort:inPort];
            [self.availableInputPorts addObject:client];
        }else
        {
            DDLogCInfo(@"port %li wasn't available", portToListen);
            
            /* Create new ports as long as the inPort variable is not null */
        }
    }
}

- (void)startObservingInputs
{
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        [currentOSCClient startObserving];
    }
    
    _portObserverTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(observeNextInputs) userInfo:nil repeats:YES];
}


- (void)observeNextInputs
{
    
    // try to
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        
        unsigned int currentPort = currentOSCClient.port;
        unsigned int newPort = (unsigned int)(currentPort + self.availableInputPorts.count);
        DDLogInfo(@"switchin input from port '%i' to new port '%i'", currentPort, newPort);
        [currentOSCClient stopObserving];
        [currentOSCClient setPort:newPort];
        [currentOSCClient startObserving];
    }
}

- (void)stopObservingInputs
{
    [_portObserverTimer invalidate];
    _portObserverTimer = nil;
}

- (NSArray *)availableInputs;
{
    return nil;
}


#pragma mark - OSCInPort Delegate
- (void)receivedOSCMessage:(OSCMessage *)message
{
    NSLog(@"did received message: %@", message);
}

@end
