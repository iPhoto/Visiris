//
//  VSExternalInputManager.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"


@interface VSExternalInputManager : NSObject


#pragma mark - input manager handling
- (void)registerExternalInputManager;

// registering new input manager
- (BOOL)registerInputManagerForClass:(Class)inputManager withIdentifier:(NSString *)theInputManagerIdentifier;

// accessing input manager
- (id<VSExternalInputProtocol>)inputManagerForIdentifier:(NSString *)aInputManagerIdentifier;


#pragma mark - getting information from registered input manager
- (void)startObservingInputs;
- (void)stopObservingInputs;

// nsarray containing VSExternlaInputs
- (NSArray *)availableInputs;


@end
