//
//  VSOSCMessage.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import <Foundation/Foundation.h>


/**
 * Simple OSC Message
 */
@interface VSOSCMessage : NSObject

/** The port the message is sent */
@property (assign) unsigned int                     port;

/** The Address of the message */
@property (strong) NSString                         *address;

/** The Value can be NSNumber, NSString or NSBool */
@property (assign) id                               value;


/**
 * Creates and Returns a VSOSCMessage
 * @param value The Value can be NSNumber, NSString or NSBool
 * @param address The Address of the message
 * @param port The port the message is sent
 * @return The new init alloc VSOSCMessage
 */
+ (id)messageWithValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port;

@end
