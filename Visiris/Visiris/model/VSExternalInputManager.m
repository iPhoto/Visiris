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
- (BOOL)registerValue:(id)value forAddress:(NSString *)address atPort:(NSUInteger)port
{
    BOOL isValueForAddressOnPortRegistered = NO;
    
    if (address) {
        
        [self.activeValueReferenceCount incrementReferenceOfKey:address];
        
        id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
        isValueForAddressOnPortRegistered = [inputManager startInputForAddress:address atPort:(unsigned int)port];
    }
    
    return isValueForAddressOnPortRegistered;
}


- (BOOL)unRegisterValue:(id)value forAddress:(NSString *)address atPort:(NSUInteger)port
{
    BOOL isValueForAddressOnPortUnregistered = NO;
    
    BOOL isAddressStillActive = [self.activeValueReferenceCount decrementReferenceOfKey:address];
    if (!isAddressStillActive) {
    
        [self.currentActiveValues removeObjectForKey:address];
        
        // delete input of specific inputManager
        id<VSExternalInputProtocol> inputManager = [self.availableInputManager objectForKey:kVSInputManager_OSC];
        isValueForAddressOnPortUnregistered = [inputManager stopInputForAddress:address atPort:(unsigned int)port];
    }
    
    return isValueForAddressOnPortUnregistered;
}


@end
