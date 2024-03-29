//
//  VSExternalInputProtocol.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputManagerDelegate.h"


@protocol VSExternalInputProtocol <NSObject>



@required

@property (weak)id<VSExternalInputManagerDelegate>              delegate;

// managing input sniffer
- (void)startObservingInputs;
- (void)stopObservingInputs;

- (NSArray *)availableInputs;


// managing concrete inputs
- (BOOL)startInputForAddress:(NSString *)address atPort:(unsigned int)port;
- (BOOL)stopInputForAddress:(NSString *)address atPort:(unsigned int)port;


@end
