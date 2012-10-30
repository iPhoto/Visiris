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

@property (assign) float    oldValue;
@property (strong) NSDate   *oldDate;
//@property (assign) BOOL     old

@end

@implementation VSDeviceParameterMapper

#define kDeviceParameter @"DeviceParamete"
#define kDevice @"Device"
#define kParameterRange @"ParameterRange"
#define kDeviceParameterRange @"DeviceParamterRange"
#define kDeviceParameterIdentifier @"DeviceParameterIdentifier"
#define kHasRange @"HasRange"

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device deviceParameterRange:(VSRange)deviceParameterRange andParameterRange:(VSRange)parameterRange{
    
    if(self = [self initWithDeviceParameter:deviceParameter ofDevice:device]){
        self.parameterRange = parameterRange;
        self.deviceParameterRange = deviceParameterRange;
        
        self.hasRanges = YES;
        self.oldValue = 0.0f;
//        self.
    }
    
    return self;
}

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    
    if(self = [self init]){
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
    [aCoder encodeObject:self.deviceParameter.identifier forKey:kDeviceParameterIdentifier];
    [aCoder encodeObject:self.device forKey:kDevice];
    VSRangeEncode(aCoder, self.deviceParameterRange, kDeviceParameterRange);
    VSRangeEncode(aCoder, self.parameterRange, kParameterRange);
}

-(id) initWithCoder:(NSCoder *)aDecoder{

    VSDevice *device = [aDecoder decodeObjectForKey:kDevice];
    NSString *deviceParameterIdentifier = [aDecoder decodeObjectForKey:kDeviceParameterIdentifier];
    VSDeviceParameter *deviceParameter = [device parameterIdentifiedBy:deviceParameterIdentifier];
    
    if(deviceParameter.hasRange){
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
    
    y = [self smoothValue:y withSmoothing:0.95f];
    
    return  y;
}

- (float)smoothValue:(float)value withSmoothing:(float)smoothness
{
    float result;
    
    result = self.oldValue * smoothness + value * (1.0f - smoothness);
    
//    hier wird die smoothness anders eingestellt
//    float k = (value - self.oldValue)/smoothness;
//    result = k * (-[self.oldDate timeIntervalSinceNow]) + self.oldValue;
//    self.oldDate = [[NSDate alloc] init];

    self.oldValue = result;
    return result;
}

@end
