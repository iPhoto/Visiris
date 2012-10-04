//
//  VSExternalInputManagerDelegate.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/4/12.
//
//

#import <Foundation/Foundation.h>
#import "VSExternalInputProtocol.h"

@protocol VSExternalInputProtocol;

@protocol VSExternalInputManagerDelegate <NSObject>

- (void)inputManager:(id<VSExternalInputProtocol>)inputManager didReceivedValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port;

@end
