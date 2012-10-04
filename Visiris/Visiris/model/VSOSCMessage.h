//
//  VSOSCMessage.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@interface VSOSCMessage : NSObject

@property (assign) unsigned int                     port;
@property (strong) NSString                         *address;
@property (assign) id                               value;

+ (id)messageWithValue:(id)value forAddress:(NSString *)address atPort:(unsigned int)port;

@end
