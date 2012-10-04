//
//  VSDeviceAnimation.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceParameterMapper.h"

@implementation VSDeviceParameterMapper

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device deviceParameterRange:(VSRange)deviceParameterRange andParameterRange:(VSRange)parameterRange{
    
    if(self = [super init]){
        self.device = device;
        self.deviceParameter = deviceParameter;
        self.parameterRange = parameterRange;
        self.deviceParameterRange = deviceParameterRange;
        

    }
    
    return self;
}

-(float) currentMappedParameterValue{
    float currentValue =fmodf(arc4random(), (self.deviceParameterRange.max - self.deviceParameterRange.min) ) + self.deviceParameterRange.min;
    
    return [self mapValue:currentValue fromRange:self.deviceParameterRange toRange:self.parameterRange];
}

- (float)mapValue:(float)value fromRange:(VSRange)inRange toRange:(VSRange)outRange{
    
    float y, k, deltaY, deltaX, d, x;
    
    x = value - inRange.min;
    
    d = outRange.min;
    
    deltaY = outRange.max - outRange.min;
    deltaX = inRange.max - inRange.min;
    
    k = deltaY/deltaX;
    
    y = k * x + d;
    
    return  y;
}

@end
