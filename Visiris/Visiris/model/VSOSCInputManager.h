//
//  VSOSCInputManager.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"
#import "VSOSCClientPortListener.h"


#define kVSInputManager_OSC @"kVSInputManager_OSC"

@interface VSOSCInputManager : NSObject <VSExternalInputProtocol, VSOSCClientPortListener>

+ (NSString *)identifier;

#pragma mark - Available OSC ports observation
// VSExternalInputProtocol implementation
- (void)startObservingInputs;
- (void)stopObservingInputs;

- (NSArray *)availableInputs;


- (BOOL)startInputForAddress:(NSString *)address;
- (BOOL)stopInputForAddress:(NSString *)address;


#pragma mark - VSOSCClient Management
- (BOOL)startOSCClientOnPort:(unsigned int)port;
- (BOOL)stopOSCClientOnPort:(unsigned int)port;


@end
