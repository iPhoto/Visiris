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

-(BOOL) willRemoveExternalInputs:(NSArray*) fromInputManager:(id<VSExternalInputProtocol>) manager;

-(void) didRemoveExternalInputs:(NSArray*) fromInputManager:(id<VSExternalInputProtocol>) manager;

-(BOOL) willAddExternalInputs:(NSArray*) fromInputManager:(id<VSExternalInputProtocol>) manager;

-(void) didAddExternalInputs:(NSArray*) fromInputManager:(id<VSExternalInputProtocol>) manager;

@end
