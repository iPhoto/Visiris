//
//  VSExternalInputProtocol.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>


@protocol VSExternalInputProtocol <NSObject>

@required

// managing input sniffer
- (void)startObservingInputs;
- (void)stopObservingInputs;

- (NSArray *)availableInputs;


// managing concrete inputs
- (void)startInputForAddress:(NSString *)address atPort:(unsigned int)port;
- (void)stopInputForAddress:(NSString *)address atPort:(unsigned int)port;


@end
