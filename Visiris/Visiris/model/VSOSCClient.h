//
//  VSOSCClient.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import <VVOSC/VVOSC.h>

@interface VSOSCClient : NSObject

@property (nonatomic, assign) unsigned short                           port;

- (id)initWithOSCInPort:(OSCInPort *)oscInPort;

- (void)startObserving;

- (void)stopObserving;


@end
