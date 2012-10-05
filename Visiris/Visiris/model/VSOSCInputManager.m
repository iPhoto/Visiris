//
//  VSOSCInputManager.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <VVOSC/VVOSC.h>
#import "VSOSCInputManager.h"

// Core Services
#import "VSCoreServices.h"

// VSOSC
#import "VSOSCClient.h"
#import "VSOSCPort.h"
#import "VSOSCMessage.h"


#define kVSOSCInputManager_inputRangeStart @"kVSOSCInputManager_inputRangeStart"
#define kVSOSCInputManager_inputRangeEnd @"kVSOSCInputManager_inputRangeEnd"

#define kVSOSCInputManager_numberOfDefalutOSCListenPorts 5
#define kVSOSCInputManager_oscPortWalkthroughInterval 1.0f
#define kVSOSC_unusedPortLifetime 10

@interface VSOSCInputManager ()
{
    NSRange                                             _observablePorts;
    
    NSTimer                                             *_portObserverTimer;
    NSTimer                                             *_activePortListRefreshTimer;
    
    OSCManager                                          *_oscManager;
    
    unsigned int                                        _lastAssignedPort;
    NSUInteger                                          _numberOfInputClients;
    
    dispatch_source_t                                   _oscPortUpdateTimer;
    dispatch_queue_t                                    _oscPortUpdateQueue;
}

@property (strong) NSMutableArray                       *availableInputPorts;
@property (strong) NSMutableDictionary                  *activePorts;
@property (strong) NSMutableDictionary                  *activeOSCClients;

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
        
        _observablePorts = NSMakeRange(4250, 4300);
        
        /* TODO: Implement Preference Panel
        observablePorts.location = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeStart];
        observablePorts.length = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeEnd];
        */
        
        _activeOSCClients = [[NSMutableDictionary alloc] init];
        
        _oscPortUpdateQueue = dispatch_queue_create("com.graftinc.visiris.oscInputQueue", NULL);
        _oscPortUpdateTimer = NULL;
        
        
        _lastAssignedPort = (unsigned int)_observablePorts.location;
        
        NSUInteger oscPortCount = _observablePorts.length - _observablePorts.location;
        _numberOfInputClients =  oscPortCount < kVSOSCInputManager_numberOfDefalutOSCListenPorts ? oscPortCount : kVSOSCInputManager_numberOfDefalutOSCListenPorts;
        
        _activePorts = [[NSMutableDictionary alloc] init];
        
        self.availableInputPorts = [[NSMutableArray alloc] initWithCapacity:_numberOfInputClients];
        [self createInputObserver:_numberOfInputClients atStartPort:_observablePorts.location];
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_oscPortUpdateTimer);
    dispatch_release(_oscPortUpdateQueue);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", kVSInputManager_OSC];
}

#pragma mark - VSExternalInputProtocol implementation
- (void)createInputObserver:(NSInteger)numberOfClientToCreate atStartPort:(NSUInteger)startPort
{
    unsigned int currentPort = (unsigned int)startPort-1;
    
    for (NSInteger i = 0; i < numberOfClientToCreate; i++) {
        
        OSCInPort *inPort = nil;
        
        while (!inPort) {
            
            currentPort = [self getNextAvailableOSCPort];
            
            inPort = [_oscManager createNewInputForPort:currentPort];

            if (inPort) {
                [inPort stop];
                
                VSOSCClient *client = [[VSOSCClient alloc] initWithOSCInPort:inPort andType:VSOSCClientPortSniffer];
                client.delegate = self;
                client.port = [inPort port];
                [self.availableInputPorts addObject:client];

                break;
            }
        }
    }
}

- (void)startObservingInputs
{
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        [currentOSCClient startObserving];
    }
    
    if ( self.availableInputPorts.count )
    {
        _portObserverTimer = [NSTimer scheduledTimerWithTimeInterval:kVSOSCInputManager_oscPortWalkthroughInterval target:self selector:@selector(observeNextInputs) userInfo:nil repeats:YES];
    }
    
    [self startActivePortObservation];
}


- (void)observeNextInputs
{
    // try to
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        
//        unsigned int currentPort = currentOSCClient.port;
        unsigned int newPort = [self getNextAvailableOSCPort];
        
        
        [currentOSCClient stopObserving];
        [currentOSCClient setPort:newPort];
        while (![currentOSCClient isBinded]) {
            
            [currentOSCClient setPort:[self getNextAvailableOSCPort]];
        }
        [currentOSCClient startObserving];
    }
}

- (unsigned int)getNextAvailableOSCPort
{
    _lastAssignedPort++;
    if ( _lastAssignedPort > _observablePorts.length ) {
        _lastAssignedPort = (unsigned int)_observablePorts.location;
    }
    
    return _lastAssignedPort;
}

- (void)stopObservingInputs
{
    [_portObserverTimer invalidate];
    _portObserverTimer = nil;
    
    [self stopActivePortObservation];
}

- (NSArray *)availableInputs;
{
    VSOSCPort *port = [VSOSCPort portWithPort:12345 address:@"/Visiris/Rocks" atTimestamp:[NSDate timeIntervalSinceReferenceDate]];
    [port addAddress:@"/Visiris/OSC/Rocks"];
    [port addAddress:@"/Visiris/MIDI/AHHH"];
    
    NSArray *array = [NSArray arrayWithObject:port];
    return array;
}

- (BOOL)startInputForAddress:(NSString *)address atPort:(unsigned int)port
{
    
    BOOL isInputForAddressActive = NO;
    // get the port from address
    
    if (address) {
        
        for (VSOSCClient *currentClient in self.availableInputPorts) {
            
            if (currentClient.port == port) {

                // stop sniffer port
                [currentClient stopObserving];
                
                // re activate current sniffer
                currentClient.port = [self getNextAvailableOSCPort];
                [currentClient startObserving];
                
                break;
            }
        }
        
        isInputForAddressActive = [self startOSCClientOnPort:port];
    }
    
    return isInputForAddressActive;
}


- (BOOL)stopInputForAddress:(NSString *)address atPort:(unsigned int)port
{
    BOOL isInputForAddressStopped = NO;
    
    if (address) {
        
        [self stopOSCClientOnPort:port];
    }
    
    return isInputForAddressStopped;
}


#pragma mark - Updating OSC Ports

- (dispatch_source_t)oscPortDispatchTimerWithInterval:(uint64_t)interval onQueue:(dispatch_queue_t)dispatchQueue withBlock:(dispatch_block_t)block
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, dispatchQueue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, 1ull*NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)startActivePortObservation
{

    if (  !_oscPortUpdateTimer) {
        _oscPortUpdateTimer = [self oscPortDispatchTimerWithInterval:10ull*NSEC_PER_SEC onQueue:_oscPortUpdateQueue withBlock:[self updateAvailableOSCPortsBlock]];
    }else
    {
        dispatch_resume(_oscPortUpdateTimer);
    }
}



- (dispatch_block_t)updateAvailableOSCPortsBlock
{
    __weak VSOSCInputManager *refSelf = self;
    return ^{
        
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        
        NSArray *allDiscoveredPorts = [refSelf.activePorts allValues];
        NSMutableArray *outdatedPorts = [NSMutableArray array];
        
        for (VSOSCPort *currentPort in allDiscoveredPorts) {
            
            NSTimeInterval difference = now - currentPort.lastMessageReceivedTimestamp;
            if ( difference  > kVSOSC_unusedPortLifetime ) {
                [outdatedPorts addObject:[NSNumber numberWithUnsignedInt:currentPort.port]];
            }
        }
        
        [refSelf.activePorts removeObjectsForKeys:outdatedPorts];
        DDLogInfo(@"active ports: %@", refSelf.activePorts);        
    };
}

- (void)stopActivePortObservation
{
    dispatch_suspend(_oscPortUpdateTimer);
}


#pragma mark - VSOSCClient Management
- (BOOL)startOSCClientOnPort:(unsigned int)port
{
    BOOL oscClientStarted = NO;
    
    //edi
    
    VSOSCClient *tempClient = [self.activeOSCClients objectForKey:[NSNumber numberWithUnsignedInt:port]];
    if (tempClient)
    {
        oscClientStarted = YES;
    }
    else
    {
        OSCInPort *inPort = [_oscManager createNewInputForPort:port];

        VSOSCClient *oscClient = [[VSOSCClient alloc] initWithOSCInPort:inPort andType:VSOSCClientActiveReceiver];
        if (oscClient) {

            oscClientStarted = YES;
            [oscClient setPort:port];
            [oscClient setDelegate:self];
            
            [self.activeOSCClients setObject:oscClient forKey:[NSNumber numberWithUnsignedInt:port]];
        }
    }
    
    
    
    [self printDebugLog];
    
    
    return oscClientStarted;
}


- (BOOL)stopOSCClientOnPort:(unsigned int)port
{
    BOOL oscClientStopped = NO;
    
    VSOSCClient *client = [self.activeOSCClients objectForKey:[NSNumber numberWithUnsignedInt:port]];
    if (client) {
        oscClientStopped = YES;
        
        [client stopObserving];
    }
    
    return oscClientStopped;
}

#pragma mark - VSOSCClientDelegate
- (void)oscClient:(VSOSCClient *)client didReceivedMessage:(VSOSCMessage *)message
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(inputManager:didReceivedValue:forAddress:atPort:)]) {
            DDLogInfo(@"message: %@",message);
            [self.delegate inputManager:self didReceivedValue:message.value forAddress:message.address atPort:message.port];
        }
    }
}

- (void)oscClient:(VSOSCClient *)client didDiscoveredActivePort:(VSOSCPort *)discoveredPort
{
    VSOSCPort *port = [self.activePorts objectForKey:[NSNumber numberWithUnsignedInt:discoveredPort.port]];
    if (!port) {
        [self.activePorts setObject:discoveredPort forKey:[NSNumber numberWithUnsignedInt:discoveredPort.port]];
    }else
    {
        [port addAddress:[discoveredPort.addresses objectAtIndex:0]];
    }
}


#pragma mark - OSCInPort Delegate
//- (void)receivedOSCMessage:(OSCMessage *)message
//{
//    NSLog(@"did received message: %@", message);
//    
//
//}


#pragma mark - Internal Methods
- (unsigned int)portForAddress:(NSString *)address
{
    unsigned int requestedPort = 0;
    
    for (VSOSCPort *port in self.activePorts) {
        
        if ([port.addresses containsObject:address]) {
            requestedPort = port.port;
            break;
        }
    }
    
    return requestedPort;
}

- (void)printDebugLog
{
    DDLogInfo(@"===PRINT DEBUG LOG===");
    DDLogInfo(@"activeOSCClients");
    for (id key in self.activeOSCClients) {
        NSLog(@"key: %@, value: %@", key, [self.activeOSCClients objectForKey:key]);
    }
}

@end
