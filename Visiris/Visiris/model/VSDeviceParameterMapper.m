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

@interface VSDeviceParameterMapper()

@property (assign) float oldValue;

@end

@implementation VSDeviceParameterMapper

#define kDeviceParameter @"DeviceParamete"
#define kDevice @"Device"
#define kParameterRange @"ParameterRange"
#define kDeviceParameterRange @"DeviceParamterRange"
#define kHasRange @"HasRange"

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device deviceParameterRange:(VSRange)deviceParameterRange andParameterRange:(VSRange)parameterRange{
    
    if(self = [self initWithDeviceParameter:deviceParameter ofDevice:device]){
        self.parameterRange = parameterRange;
        self.deviceParameterRange = deviceParameterRange;
        
        self.hasRanges = YES;
        self.oldValue = 0.0f;
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

-(id) copyWithZone:(NSZone *)zone{
    VSDeviceParameterMapper *copy;
    
    if(self.hasRanges){
        copy = [[VSDeviceParameterMapper allocWithZone:zone] initWithDeviceParameter:self.deviceParameter
                                                                            ofDevice:self.device];
    }
    else{
        copy = [[VSDeviceParameterMapper allocWithZone:zone] initWithDeviceParameter:self.deviceParameter
                                                                            ofDevice:self.device  deviceParameterRange:self.deviceParameterRange andParameterRange:self.parameterRange];
    }
    
    return copy;
}

-(void) dealloc{
    [self.device deactivateParameter:self.deviceParameter];
}

-(float)currentMappedParameterFloatValue{
    return [self mapValue:[self.deviceParameter currentFloatValue] fromRange:self.deviceParameterRange toRange:self.parameterRange];
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.deviceParameter forKey:kDeviceParameter];
    [aCoder encodeObject:self.device forKey:kDevice];
    VSRangeEncode(aCoder, self.deviceParameterRange, kDeviceParameterRange);
    VSRangeEncode(aCoder, self.parameterRange, kParameterRange);
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    BOOL hasRange = [aDecoder decodeBoolForKey:kHasRange];
    VSDevice *device = [aDecoder decodeObjectForKey:kDevice];
    VSDeviceParameter *deviceParameter = [aDecoder decodeObjectForKey:kDeviceParameter];
    
    
    if(hasRange){
        NSError *error;
        VSRange parameterDeviceRange = VSRangeDecode(aDecoder, kDeviceParameterRange, &error);
        
        if(error){
            DDLogError(@"%@",error);
            return nil;
        }
        
        VSRange parameterRange = VSRangeDecode(aDecoder, kParameterRange, &error);
        
        if(error){
            DDLogError(@"%@",error);
            return nil;
        }
        
        return [self initWithDeviceParameter:deviceParameter
                                    ofDevice:device
                        deviceParameterRange:parameterDeviceRange
                           andParameterRange:parameterRange];
    }
    else{
        return [self initWithDeviceParameter:deviceParameter
                                    ofDevice:device];
    }
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

- (float)smoothValueWithIntensity:(float)intensity
{
    
    
    
    
    
    
    return 0.0f;
}

@end
