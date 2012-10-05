//
//  VSExternalInputManager.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSExternalInputManager.h"

// Visiris Input Manager
#import "VSOSCInputManager.h"


#import <VisirisCore/VSReferenceCounting.h>



#import "VSCoreServices.h"



@interface VSExternalInputManager ()

@property (strong) NSMutableDictionary                              *availableInputManager;
@property (strong) NSMutableDictionary                              *availableParameter;

@property (strong) NSMutableDictionary                              *currentActiveValues;

@property (strong) VSReferenceCounting                              *activeValueReferenceCount;

@end


@implementation VSExternalInputManager

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        
        self.availableInputManager = [[NSMutableDictionary alloc] init];
        
        self.activeValueReferenceCount = [[VSReferenceCounting alloc] init];
        
        self.currentActiveValues = [[NSMutableDictionary alloc] init];
        
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


- (NSArray *)availableInputs
{
    NSMutableArray *availableInputs = [NSMutableArray array];

    for (id<VSExternalInputProtocol> inputManager in [self.availableInputManager allValues]) {
        [availableInputs addObjectsFromArray:[inputManager availableInputs]];
    }
    
    return availableInputs;
}

// DeviceParameterRegistrationDelegate
- (BOOL)registerValue:(NSInvocation *)parameterInvocation forAddress:(NSString*)parameterAddress atPort:(NSUInteger)port
{
    BOOL isValueForAddressOnPortRegistered = NO;
    
    if (parameterAddress) {
        
        [self.activeValueReferenceCount incrementReferenceOfKey:parameterAddress];
        
        [self.currentActiveValues setObject:parameterInvocation forKey:[NSString stringFromAddress:parameterAddress atPort:(unsigned int)port]];
        
        id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
        isValueForAddressOnPortRegistered = [inputManager startInputForAddress:parameterAddress atPort:(unsigned int)port];
    }
    
    return isValueForAddressOnPortRegistered;
}


- (BOOL)unregisterValue:(NSInvocation *)parameterInvocation forAddress:(NSString*)parameterAddress atPort:(NSUInteger)port
{
    BOOL isValueForAddressOnPortUnregistered = NO;
    
    if (parameterAddress) {
        
        BOOL isAddressStillActive = [self.activeValueReferenceCount decrementReferenceOfKey:parameterAddress];
        if (!isAddressStillActive) {
            
            [self.currentActiveValues removeObjectForKey:[NSString stringFromAddress:parameterAddress atPort:(unsigned int)port]];
            
            // delete input of specific inputManager
            id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
            isValueForAddressOnPortUnregistered = [inputManager stopInputForAddress:parameterAddress atPort:(unsigned int)port];
        }
    }
    
    return isValueForAddressOnPortUnregistered;
}

#pragma mark VSExternalInputManagerDelegate
- (void)inputManager:(id<VSExternalInputProtocol>)inputManager didReceivedValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port
{
    if (address && value && inputManager) {
        
        NSInvocation *invocation = [self.currentActiveValues objectForKey:[NSString stringFromAddress:address atPort:port]];

        [invocation setArgument:&value atIndex:2];        
        [invocation invoke];
    }
}
@end
