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



#import "VSCoreServices.h"



@interface VSExternalInputManager ()

@property (strong) NSMutableDictionary                          *availableInputManager;
@property (strong) NSMutableDictionary                          *availableParameter;

@end


@implementation VSExternalInputManager

- (id)init
{
    self = [super init];
    if (self) {
        
        self.availableInputManager = [[NSMutableDictionary alloc] init];
        
        [self registerExternalInputManager];
        
        // TODO: move next line to somewhere usefull (start observing inputs after window did finish loading and app is running in idle mode)
        [self startObservingInputs];
    }
    
    return self;
}

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
@end
