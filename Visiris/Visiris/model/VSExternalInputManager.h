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

/**
 * VSExternalInputManager is for handling all the external Inputs (OSC, MIDI,....)
 */
@interface VSExternalInputManager : NSObject<VSDeviceParameterRegistrationDelegate, VSExternalInputManagerDelegate>

/** ExternalInputManager is a singleton class. This Method returns the singleton instance */
+(VSExternalInputManager*)sharedExternalInputManager;


#pragma mark - input manager handling

/** The Array holding the current available Inputs as ExternalInputobjects */
@property (strong, readonly) NSMutableArray *availableInputs;

/**
 * Is for registering an ExternalInputmanager which has to include the ExternalInputProtocol
 * @param inputManager The new InputManager
 * @param theInputManagerIdentifier The identifier of a InputManager
 * @return YES when succersfully registered
 */
- (BOOL)registerInputManagerForClass:(Class)inputManager withIdentifier:(NSString *)theInputManagerIdentifier;

/**
 * Accessing an specific InputManager
 * @param aInputManagerIdentifier The Unique identifier for accessing the Manager
 * @return the Inputmanager which corresponds to the VSExternalInputProtocol
 */
- (id<VSExternalInputProtocol>)inputManagerForIdentifier:(NSString *)aInputManagerIdentifier;


#pragma mark - getting information from registered input manager

/** Start sniffing ports and listening to inputs */
- (void)startSniffer;

/** Stop sniffing ports */
- (void)stopSniffer;

//todo document with andi 
// DeviceParameterRegistrationDelegate
-(BOOL) registerValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier;
-(BOOL) unregisterValue:(NSInvocation *)parameterInvocation forIdentifier:(NSString *)identifier;


@end
