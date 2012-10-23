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


@interface VSExternalInputManager : NSObject<VSDeviceParameterRegistrationDelegate, VSExternalInputManagerDelegate>

+(VSExternalInputManager*)sharedExternalInputManager;

#pragma mark - input manager handling

@property (strong, readonly) NSMutableArray *availableInputs;

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



// DeviceParameterRegistrationDelegate
-(BOOL) registerValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier;
-(BOOL) unregisterValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier;


@end
