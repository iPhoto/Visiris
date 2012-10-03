//
//  VSOSCClientPortListener.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@class VSOSCClient;
@class VSOSCMessage;
@class VSOSCPort;

@protocol VSOSCClientPortListener <NSObject>

// message handling
- (void)oscClient:(VSOSCClient *)client didReceivedMessage:(VSOSCMessage *)message;

// port sniffing
- (void)oscClient:(VSOSCClient *)client didDiscoveredActivePort:(VSOSCPort *)port;

@end
