//
//  VSOSCAddress.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/11/12.
//
//

#import "VSOSCAddress.h"

@implementation VSOSCAddress

+ (VSOSCAddress *)addressWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeStamp
{
    return [[VSOSCAddress alloc] initWithAddress:address timeStamp:timeStamp];
}

- (id)initWithAddress:(NSString *)address timeStamp:(NSTimeInterval)timeStamp
{
    self = [super init];
    if (self) {
        self.address = address;
        self.lastReceivedAddressTimestamp = timeStamp;
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object
{
    BOOL isEqualTo = NO;
    
    
    if ( [self.address isEqualToString:[(VSOSCAddress *)object address]] ) {
        isEqualTo = YES;
    }
    
    return isEqualTo;
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    
    
    if ( [self.address isEqualToString: [(VSOSCAddress *)object address]] ) {
        isEqual = YES;
    }
    
    return isEqual;
}

@end
