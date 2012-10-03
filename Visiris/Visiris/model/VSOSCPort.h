//
//  VSOSCPort.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@interface VSOSCPort : NSObject

@property (assign) unsigned int                         port;
@property (strong) NSMutableArray                       *addresses;
@property (assign) double                               lastMessageReceivedTimestamp;

+ (VSOSCPort *)portWithPort:(unsigned int)port address:(NSString *)address atTimestamp:(double)timestamp;

- (void)addAddress:(NSString *)address;

@end
