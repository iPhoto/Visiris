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
#import "VSOSCInput.h"

#import "VSExternalInput.h"

#import <VisirisCore/VSReferenceCounting.h>


#define kVSOSCInputManager_inputRangeStart @"kVSOSCInputManager_inputRangeStart"
#define kVSOSCInputManager_inputRangeEnd @"kVSOSCInputManager_inputRangeEnd"

#define kVSOSCInputManager_numberOfDefalutOSCListenPorts 5
#define kVSOSCInputManager_oscPortWalkthroughInterval 1.0f
#define kVSOSC_unusedPortLifetime 10000

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

@property (strong) NSMutableArray                       *snifferClients;
@property (strong) NSMutableDictionary                  *discoveredPorts;

@property (strong) NSMutableDictionary                  *activeOSCClients;
@property (strong) VSReferenceCounting                  *referenceCountingPorts;

@property (strong) VSReferenceCounting                  *referencCountingAdresses;


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
        self.referenceCountingPorts = [[VSReferenceCounting alloc] init];
        self.referencCountingAdresses = [[VSReferenceCounting alloc] init];
        
        _observablePorts = NSMakeRange(12340,12350);
        
        /* TODO: Implement Preference Panel
        observablePorts.location = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeStart];
        observablePorts.length = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeEnd];
        */
        
        _activeOSCClients = [[NSMutableDictionary alloc] init];
        
        _oscPortUpdateQueue = dispatch_queue_create("com.graftinc.visiris.oscInputQueue", NULL);
        _oscPortUpdateTimer = NULL;
        
        
        _lastAssignedPort = (unsigned int)_observablePorts.location - 1;
        
        NSUInteger oscPortCount = _observablePorts.length - _observablePorts.location;
        
        _numberOfInputClients =  oscPortCount < kVSOSCInputManager_numberOfDefalutOSCListenPorts ? oscPortCount : kVSOSCInputManager_numberOfDefalutOSCListenPorts;
        
        _discoveredPorts = [[NSMutableDictionary alloc] init];
        
        self.snifferClients = [[NSMutableArray alloc] initWithCapacity:_numberOfInputClients];
        [self createInputObserver:_numberOfInputClients];
        
    }
    
    return self;
}

- (void)dealloc
{
    if (_oscPortUpdateTimer) {
        dispatch_release(_oscPortUpdateTimer);
    }
    
    if (_oscPortUpdateQueue) {
        dispatch_release(_oscPortUpdateQueue);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", kVSInputManager_OSC];
}

#pragma mark - AvailableOSCPortObserverCreation
- (void)createInputObserver:(NSInteger)numberOfClientToCreate
{    
    for (NSInteger i = 0; i < numberOfClientToCreate; i++)
    {
        OSCInPort *inPort = nil;
        
        while (!inPort)
        {
            unsigned int currentPort = [self getNextAvailableOSCPort];
            inPort = [_oscManager createNewInputForPort:currentPort];
        
            //todo startet hier schon das erste observing?
            if (inPort)
            {
                [inPort stop];
                
                VSOSCClient *client = [[VSOSCClient alloc] initWithOSCInPort:inPort
                                                                     andType:VSOSCClientPortSniffer];
                client.delegate = self;
                client.port = [inPort port];
                [self.snifferClients addObject:client];

                break;
            }
        }
    }
}

#pragma mark - VSExternalInputProtocol implementation
- (void)startObservingInputs
{
    for (VSOSCClient *currentOSCClient in self.snifferClients) {
        [currentOSCClient startObserving];
    }
    
    if ( self.snifferClients.count )
    {
        _portObserverTimer = [NSTimer scheduledTimerWithTimeInterval:kVSOSCInputManager_oscPortWalkthroughInterval target:self selector:@selector(observeNextInputs) userInfo:nil repeats:YES];
    }
    
    [self startActivePortObservation];
}

- (void)stopObservingInputs
{
    [_portObserverTimer invalidate];
    _portObserverTimer = nil;
    
    [self stopActivePortObservation];
}

#pragma mark External Input Helper
- (void)observeNextInputs
{
    // try to
    for (VSOSCClient *currentOSCClient in self.snifferClients) {
        
        //        unsigned int currentPort = currentOSCClient.port;
        
        [currentOSCClient stopObserving];
        
        unsigned int newPort;
        
        do
        {
            newPort = [self getNextAvailableOSCPort];
            [currentOSCClient setPort:newPort];
        }
        while (![currentOSCClient isBinded]);
        
//        NSLog(@"Start observing Port: %d",newPort);
        
        [currentOSCClient startObserving];
    }
//    [self printDebugLog];
}

- (unsigned int)getNextAvailableOSCPort
{
    _lastAssignedPort++;
    if ( _lastAssignedPort > _observablePorts.length ) {
        _lastAssignedPort = (unsigned int)_observablePorts.location;
    }
    
    return _lastAssignedPort;
}


- (NSArray *)availableInputs;
{
    /* define return format of available input ports with addresses */
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (VSOSCPort *port in [self.discoveredPorts allValues])
    {
        [array addObjectsFromArray:port.addresses];
    }
    
    return array;
}

- (BOOL)startInputForAddress:(NSString *)address atPort:(unsigned int)port
{
    BOOL isInputForAddressActive = NO;
    // get the port from address
    
    if (address) {
        
        for (VSOSCClient *currentClient in self.snifferClients) {
            
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
        
        [self.referencCountingAdresses incrementReferenceOfKey:[NSString stringFromAddress:address atPort:port]];
        [self.referenceCountingPorts incrementReferenceOfKey:[NSNumber numberWithUnsignedInt:port]];
    }

    return isInputForAddressActive;
}


- (BOOL)stopInputForAddress:(NSString *)address atPort:(unsigned int)port
{
    BOOL isInputForAddressStopped = NO;
    
    [self.referencCountingAdresses decrementReferenceOfKey:[NSString stringFromAddress:address atPort:port]];
    
    if (address && [self.referenceCountingPorts decrementReferenceOfKey:[NSNumber numberWithUnsignedInt:port]] == NO) {
        
        [self stopOSCClientOnPort:port];
        isInputForAddressStopped = YES;
        DDLogInfo(@"Stopped Port: %d",port);
        
    }
    
    return isInputForAddressStopped;
}


#pragma mark - Updating OSC Ports

- (dispatch_source_t)oscPortDispatchTimerWithInterval:(uint64_t)interval onQueue:(dispatch_queue_t)dispatchQueue withBlock:(dispatch_block_t)block
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, dispatchQueue);
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
    if (  !_oscPortUpdateTimer)
    {
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
        
        NSArray *allDiscoveredPorts = [refSelf.discoveredPorts allValues];
        NSMutableArray *outdatedPorts = [NSMutableArray array];
        
        for (VSOSCPort *currentPort in allDiscoveredPorts) {
            
            
            NSMutableArray *outdatedAddress = [NSMutableArray array];
            for (VSOSCInput *address in currentPort.addresses) {
                NSTimeInterval difference = now - address.lastReceivedAddressTimestamp;
                if ( difference > kVSOSC_unusedPortLifetime ) {
                    [outdatedAddress addObject:address];
                }
            }
            
            // inform delegate about removing inputs
            [currentPort.addresses removeObjectsInArray:outdatedAddress];

            if ( 0 == currentPort.addresses.count ) {
                [outdatedPorts addObject:[NSNumber numberWithUnsignedInt:currentPort.port]];
            }
        }
        
        if (outdatedPorts.count > 0) {
            [refSelf.discoveredPorts removeObjectsForKeys:outdatedPorts];
        }
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
    if (self.delegate && [self.referencCountingAdresses isObjectExisting:[NSString stringFromAddress:message.address atPort:message.port]])
    {
        if ([self.delegate respondsToSelector:@selector(inputManager:didReceivedValue:forIdentifier:)]){
            [self.delegate inputManager:self didReceivedValue:message.value forIdentifier:[NSString stringFromAddress:message.address atPort:message.port]];
        }
    }
    else{
        //DDLogInfo(@"Message Rejected: %@", [NSString stringFromAddress:message.address atPort:message.port]);
    }
}

- (void)oscClient:(VSOSCClient *)client didDiscoveredActivePort:(VSOSCPort *)discoveredPort
{
    VSOSCPort *port = [self.discoveredPorts objectForKey:[NSNumber numberWithUnsignedInt:discoveredPort.port]];
    
    if (!port)
    {
        [self.discoveredPorts setObject:discoveredPort forKey:[NSNumber numberWithUnsignedInt:discoveredPort.port]];
        
        //inform delegate about alle addresses added
    }
    else
    {
        port.lastMessageReceivedTimestamp = discoveredPort.lastMessageReceivedTimestamp;
           
        VSOSCInput *address = [discoveredPort.addresses objectAtIndex:0];
                
        BOOL containsAddress = NO;
        
        for (VSOSCInput *tempAddress in port.addresses)
        {
            if ([tempAddress.address isEqualToString:address.address])
            {
                tempAddress.lastReceivedAddressTimestamp = address.lastReceivedAddressTimestamp;
                containsAddress = YES;
            }
        }
        
        if (containsAddress == NO)
        {
            //inform delegate about new address
            [port addAddress:address];
        }
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
    
    for (VSOSCPort *port in self.discoveredPorts) {
        
        if ([port.addresses containsObject:address]) {
            requestedPort = port.port;
            break;
        }
    }
    
    return requestedPort;
}

- (void)printDebugLog
{
    NSLog(@"===PRINT DEBUG LOG===");
    
    if ([self.activeOSCClients count] > 0) {
        NSLog(@"+++Active OSCClients");
        for (id key in self.activeOSCClients) {
            NSLog(@"key: %@, value: %@", key, [self.activeOSCClients objectForKey:key]);
        }
    }
    
    
    if ([self.discoveredPorts count] > 0) {
        NSLog(@"+++Discovered Ports");
        
        for (VSOSCPort *port in [self.discoveredPorts allValues]) {
            NSLog(@"%@",port);
        }
    }
    
    NSLog(@"====================");
}

@end
