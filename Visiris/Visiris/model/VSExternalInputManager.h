//
//  VSExternalInputManager.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"
#import "VSDeviceManager.h"


@interface VSExternalInputManager : NSObject<VSDeviceParameterRegistrationDelegate>


#pragma mark - input manager handling
- (void)registerExternalInputManager;

// registering new input manager
- (BOOL)registerInputManagerForClass:(Class)inputManager withIdentifier:(NSString *)theInputManagerIdentifier;

// accessing input manager
- (id<VSExternalInputProtocol>)inputManagerForIdentifier:(NSString *)aInputManagerIdentifier;


// accessing parameter
//- (float)parameterForKey:(NSString *)key; ???

#pragma mark - getting information from registered input manager
- (void)startObservingInputs;
- (void)stopObservingInputs;

// nsarray containing VSExternlaInputs
- (NSArray *)availableInputs;


// DeviceParameterRegistrationDelegate
-(BOOL) registerValue:(id) parameterCurrentValue forAddress:(NSString*) parameterAddress atPort:(NSUInteger) port;
-(BOOL) unregisterValue:(id) parameterCurrentValue forAddress:(NSString*) parameterAddress atPort:(NSUInteger) port;

// ExternsInputManagerDelegate
- (void)inputManager:(id<VSExternalInputProtocol>)inputManager didReceivedValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port;

@end
