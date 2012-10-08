//
//  VSDeviceAnimation.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceParameterMapper.h"
#import "VSDeviceParameter.h"
#import "VSDevice.h"

@implementation VSDeviceParameterMapper

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device deviceParameterRange:(VSRange)deviceParameterRange andParameterRange:(VSRange)parameterRange{
    
    if(self = [self initWithDeviceParameter:deviceParameter ofDevice:device]){
        self.parameterRange = parameterRange;
        self.deviceParameterRange = deviceParameterRange;
        
        self.hasRanges = YES;
    }
    
    return self;
}

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    
    if(self = [super init]){
        self.device = device;
        self.deviceParameter = deviceParameter;
        self.hasRanges = NO;
    }
    
    return self;
}

-(void) dealloc{
    [self.device deactivateParameter:self.deviceParameter];
}

-(float)currentMappedParameterFloatValue{
    return [self mapValue:[self.deviceParameter currentFloatValue] fromRange:self.deviceParameterRange toRange:self.parameterRange];
}

-(BOOL) currentDeviceParameterBoolValue{
    return [self.deviceParameter currentBOOLValue];
}

-(BOOL) activateDeviceParameter{
    return [self.device activateParameter:self.deviceParameter];
}

-(BOOL) deactivateDeviceParameter{
    return [self.device deactivateParameter:self.deviceParameter];
}

-(NSString*) currentStringValue{
    return [self.deviceParameter currentStringValue];
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
