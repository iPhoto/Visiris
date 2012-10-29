//
//  VSOSCInputManager.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"
#import "VSExternalInputManagerDelegate.h"
#import "VSOSCClientPortListener.h"


#define kVSInputManager_OSC @"kVSInputManager_OSC"

@interface VSOSCInputManager : NSObject <VSExternalInputProtocol, VSOSCClientPortListener>

@property (weak) id<VSExternalInputManagerDelegate>                     delegate;

@property (strong,readonly) NSMutableArray *externalInputRepresentations;

+ (NSString *)identifier;

#pragma mark - Available OSC ports observation
// VSExternalInputProtocol implementation
- (void)startObservingInputs;
- (void)stopObservingInputs;

- (BOOL)startInputForAddress:(NSString *)address atPort:(unsigned int)port;
- (BOOL)stopInputForAddress:(NSString *)address atPort:(unsigned int)port;

#pragma mark - VSOSCClient Management
- (BOOL)startOSCClientOnPort:(unsigned int)port;
- (BOOL)stopOSCClientOnPort:(unsigned int)port;


@end
