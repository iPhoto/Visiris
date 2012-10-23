//
//  VSExternalInputManager.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSExternalInputManager.h"
#import "VSExternalInputProtocol.h"
#import "VSOSCInputManager.h"
#import "VSExternalInputManagerDelegate.h"
#import <VisirisCore/VSReferenceCounting.h>
#import "VSCoreServices.h"


@interface VSExternalInputManager ()

@property (strong) NSMutableDictionary                              *availableInputManager;
@property (strong) NSMutableDictionary                              *availableParameter;
@property (strong) NSMutableDictionary                              *currentActiveValues;


@end


@implementation VSExternalInputManager

@synthesize availableInputs = _availableInputs;

static VSExternalInputManager* sharedExternalInputManager = nil;

#pragma mark- Functions

+(VSExternalInputManager*)sharedExternalInputManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedExternalInputManager = [[VSExternalInputManager alloc] init];
        
    });
    
    return sharedExternalInputManager;
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        
        self.availableInputManager = [[NSMutableDictionary alloc] init];
        
        self.currentActiveValues = [[NSMutableDictionary alloc] init];
        
        _availableInputs = [[NSMutableArray alloc] init];
        
        [self registerExternalInputManager];
        
        // TODO: move next line to somewhere usefull (start observing inputs after window did finish loading and app is running in idle mode)
        [self startObservingInputs];
    }
    
    return self;
}


#pragma mark - Methods

- (void)registerExternalInputManager
{
    [self registerInputManagerForClass:[VSOSCInputManager class] withIdentifier:[VSOSCInputManager identifier]];
}

- (BOOL)registerInputManagerForClass:(Class)inputManager withIdentifier:(NSString *)theInputManagerIdentifier
{
    BOOL registeredInputManagerSuccessfully = NO;
    
    if (theInputManagerIdentifier) {
        
        id newInputManager = [[inputManager alloc] init];
        
        if ( newInputManager && [newInputManager conformsToProtocol:@protocol(VSExternalInputProtocol)] ) {
            
            [newInputManager setDelegate:self];
            
            [self.availableInputManager setObject:newInputManager forKey:theInputManagerIdentifier];
            
            registeredInputManagerSuccessfully = YES;
        }
    }
    
    return registeredInputManagerSuccessfully;
}


/** return an inputManager for a given identifier */
- (id<VSExternalInputProtocol>)inputManagerForIdentifier:(NSString *)aInputManagerIdentifier
{
    id <VSExternalInputProtocol> inputManager = nil;
    
    if ( aInputManagerIdentifier ) {
        inputManager = [self.availableInputManager objectForKey:aInputManagerIdentifier];
    }
    return inputManager;
}


- (void)startObservingInputs
{
    for (id<VSExternalInputProtocol> inputManager in [self.availableInputManager allValues]) {
        [inputManager startObservingInputs];
    }
}


- (void)stopObservingInputs
{
    for (id<VSExternalInputProtocol> inputManager in [self.availableInputManager allValues]) {
        
        [inputManager stopObservingInputs];
    }
}


// DeviceParameterRegistrationDelegate
- (BOOL)registerValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier{
    BOOL isValueForAddressOnPortRegistered = NO;
    
    if (identifier) {
        
        [self.currentActiveValues setObject:parameterInvocation forKey:identifier];
        
        NSArray *components = [identifier componentsSeparatedByString:@":"];
        
        NSString *parameterAddress = [components objectAtIndex:0];
        NSUInteger port = [[components objectAtIndex:1] integerValue];
        
        id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
        isValueForAddressOnPortRegistered = [inputManager startInputForAddress:parameterAddress atPort:(unsigned int)port];
        
        
    }
    DDLogInfo(@"availableParam: %@",self.currentActiveValues);
    return isValueForAddressOnPortRegistered;
}


- (BOOL)unregisterValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier{
    //    TODO reference counting funktioniert so noch nicht, und wird falsch nach hinten gegeben.....
    BOOL isValueForAddressOnPortUnregistered = NO;
    
    if (identifier) {
        
        
        [self.currentActiveValues removeObjectForKey:identifier];
        
        // delete input of specific inputManager
        id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
        
        NSArray *components = [identifier componentsSeparatedByString:@":"];
        
        NSString *parameterAddress = [components objectAtIndex:0];
        NSUInteger port = [[components objectAtIndex:1] integerValue];
        
        
        isValueForAddressOnPortUnregistered = [inputManager stopInputForAddress:parameterAddress atPort:(unsigned int)port];
    }
    
    DDLogInfo(@"availableParam: %@",self.currentActiveValues);
    
    return isValueForAddressOnPortUnregistered;
}


#pragma mark VSExternalInputManagerDelegate
-(void) inputManager:(id<VSExternalInputProtocol>)inputManager didReceivedValue:(id)value forIdentifier:(NSString *)identifier{
    if (identifier && inputManager) {
        
        NSInvocation *invocation = [self.currentActiveValues objectForKey:identifier];
        
        [invocation setArgument:&value atIndex:2];
        [invocation invoke];
    }
}

-(void) inputManager:(id<VSExternalInputProtocol>)inputManager startedReceivingExternalInputs:(NSArray *)externalInputs{
    [self.availableInputs addObjectsFromArray:externalInputs];
}

-(void) inputManager:(id<VSExternalInputProtocol>)inputManager stoppedReceivingExternalInputs:(NSArray *)externalInputs{
    [self.availableInputs removeObjectsInArray:externalInputs];
}

#pragma mark - Properties

-(NSMutableArray*) availableInputs{
     return [self mutableArrayValueForKey:@"availableInputs"];
}

@end
