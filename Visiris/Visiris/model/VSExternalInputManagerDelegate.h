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

- (void)inputManager:(id<VSExternalInputProtocol>)inputManager didReceivedValue:(id)value forIdentifier:(NSString*) identifier;


-(void) inputManager:(id<VSExternalInputProtocol>)inputManager  stoppedReceivingExternalInputs:(NSArray*) externalInputs;

-(void) inputManager:(id<VSExternalInputProtocol>)inputManager  startedReceivingExternalInputs:(NSArray*) externalInputs;


@end
