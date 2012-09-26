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


#define kVSOSCInputManager_inputRangeStart @"kVSOSCInputManager_inputRangeStart"
#define kVSOSCInputManager_inputRangeEnd @"kVSOSCInputManager_inputRangeEnd"

@interface VSOSCInputManager ()
{
    NSRange                                             _observablePorts;
    
    NSTimer                                             *_portObserverTimer;
    
    OSCManager                                          *_oscManager;
    
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
        
        _observablePorts = NSMakeRange(1234, 1300);
        
        /* TODO: Implement Preference Panel
        observablePorts.location = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeStart];
        observablePorts.length = [[NSUserDefaults standardUserDefaults] integerForKey:kVSOSCInputManager_inputRangeEnd];
        */
        
        int observerPorts = 1;
        self.availableInputPorts = [[NSMutableArray alloc] initWithCapacity:observerPorts];
        [self createInputObserver:NSMakeRange(_observablePorts.location, _observablePorts.location+observerPorts)];
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
    for (NSInteger i = rangeOfInputPorts.location; i < rangeOfInputPorts.length; i++) {
        
        OSCInPort *inPort = [_oscManager createNewInputForPort:(int)(rangeOfInputPorts.location+i)];
//        [inPort stop];
        VSOSCClient *client = [[VSOSCClient alloc] initWithOSCInPort:inPort];
        [self.availableInputPorts addObject:client];
    }
}

- (void)startObservingInputs
{
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        [currentOSCClient startObserving];
    }
    
    NSLog(@"started observing osc ports in range: %ld", self.availableInputPorts.count);
    
    _portObserverTimer = [NSTimer scheduledTimerWithTimeInterval:200.0f target:self selector:@selector(observeNextInputs) userInfo:nil repeats:YES];
}


- (void)observeNextInputs
{
    NSLog(@"OSCManager::observeNextInputs switch to new inputs with range: %ld", self.availableInputPorts.count);
    
    for (VSOSCClient *currentOSCClient in self.availableInputPorts) {
        
        [currentOSCClient setPort:currentOSCClient.port + self.availableInputPorts.count];
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


@end
