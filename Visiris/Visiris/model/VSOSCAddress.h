//
//  VSOSCAddress.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/11/12.
//
//

#import <Foundation/Foundation.h>

@interface VSOSCAddress : NSObject

@property (assign) NSTimeInterval                           lastReceivedAddressTimestamp;
@property (strong) NSString                                 *address;

+ (VSOSCAddress *)addressWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeInterval;

@end
