//
//  VSOSCInputManager.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"


#define kVSInputManager_OSC @"kVSInputManager_OSC"

@interface VSOSCInputManager : NSObject <VSExternalInputProtocol>

+ (NSString *)identifier;

// VSExternalInputProtocol implementation
- (void)startObservingInputs;
- (void)stopObservingInputs;

- (NSArray *)availableInputs;


@end
