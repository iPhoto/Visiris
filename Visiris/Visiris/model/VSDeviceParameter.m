//
//  VSDeviceParameter.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import "VSDeviceParameter.h"

@implementation VSDeviceParameter

-(id) initWithName:(NSString *)name oscPath:(NSString *)oscPath atPort:(NSUInteger) port fromValue:(float)fromValue toValue:(float)toValue{
    if(self = [super init]){
        self.name = name;
        self.oscPath = oscPath;
        self.port = port;
    }
    
    return self;
}

@end
