//
//  VSOSCPort.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import <Foundation/Foundation.h>


@class VSOSCAddress;

/**
 * Simple OSC Port
 */
@interface VSOSCPort : NSObject

/** Number of the Port */
@property (assign) unsigned int                         port;

/** One Port can contain multiple Addresses (Array with Strings) */
@property (strong) NSMutableArray                       *addresses;

/** Last Time the Message was received */
@property (assign) double                               lastMessageReceivedTimestamp;


+ (VSOSCPort *)portWithPort:(unsigned int)port address:(VSOSCAddress *)address atTimestamp:(double)timestamp;

- (void)addAddress:(VSOSCAddress *)address;


@end
