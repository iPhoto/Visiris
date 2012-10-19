//
//  VSOSCClient.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import <VVOSC/VVOSC.h>

#import "VSOSCClientPortListener.h"


//typedef NS_ENUM(NSUInteger, VSOSCClientType)
//{
//    VSOSCClientPortSniffer,
//    VSOSCClientActiveReceiver
//};

typedef enum
{
    VSOSCClientPortSniffer,
    VSOSCClientActiveReceiver
}VSOSCClientType;

@class VSOSCInputManager;
@interface VSOSCClient : NSObject

@property (nonatomic, assign) unsigned short                            port;
@property (nonatomic, weak) id<VSOSCClientPortListener>                 delegate;
@property (nonatomic, readonly) VSOSCClientType                         type;


- (id)initWithOSCInPort:(OSCInPort *)oscInPort andType:(VSOSCClientType)type;

- (void)startObserving;

- (void)stopObserving;

- (BOOL)isBinded;

@end
