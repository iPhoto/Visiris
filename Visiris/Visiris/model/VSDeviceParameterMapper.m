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

float const SMOOTHINGRANGEMIN = 0.7;
float const SMOOTHINGRANGEMAX = 0.98;


@interface VSDeviceParameterMapper()

@property (assign) float    oldValue;
@property (strong) NSDate   *oldDate;

@end

@implementation VSDeviceParameterMapper
@synthesize smoothing = _smoothing;

#define kDeviceParameter @"DeviceParamete"
#define kDevice @"Device"
#define kParameterRange @"ParameterRange"
#define kDeviceParameterRange @"DeviceParamterRange"
#define kDeviceParameterIdentifier @"DeviceParameterIdentifier"
#define kHasRange @"HasRange"
#define kSmoothing @"Smoothing"

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device deviceParameterRange:(VSRange)deviceParameterRange parameterRange:(VSRange)parameterRange andSmoothing:(float)smoothing{
    
    if(self = [self initWithDeviceParameter:deviceParameter ofDevice:device andSmoothing:smoothing]){
        self.parameterRange = parameterRange;
        self.deviceParameterRange = deviceParameterRange;
        self.smoothing = smoothing;
        self.hasRanges = YES;
        self.oldValue = 0.0f;
    }
    
    return self;
}

-(id) initWithDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device andSmoothing:(float)smoothing{
    
    if(self = [self init]){
        self.device = device;
        self.deviceParameter = deviceParameter;
        self.hasRanges = NO;
        self.smoothing = smoothing;
    }
    
    return self;
}

-(id) init{
    if(self = [super init]){
        active = NO;
    }
    
    return self;
}

- (void)dealloc{
    [self deactivateDeviceParameter];
}

-(id) copyWithZone:(NSZone *)zone{
    VSDeviceParameterMapper *copy;
    
    if(self.hasRanges){
        copy = [[VSDeviceParameterMapper allocWithZone:zone] initWithDeviceParameter:self.deviceParameter
                                                                            ofDevice:self.device
                                                                        andSmoothing:self.smoothing];
    }
    else{
        copy = [[VSDeviceParameterMapper allocWithZone:zone] initWithDeviceParameter:self.deviceParameter
                                                                            ofDevice:self.device
                                                                deviceParameterRange:self.deviceParameterRange
                                                                      parameterRange:self.parameterRange
                                                                        andSmoothing:self.smoothing];
    }
    
    return copy;
}


-(float)currentMappedParameterFloatValue{
    return [self mapValue:[self.deviceParameter currentFloatValue] fromRange:self.deviceParameterRange toRange:self.parameterRange];
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.deviceParameter.identifier forKey:kDeviceParameterIdentifier];
    [aCoder encodeObject:self.device forKey:kDevice];
    [aCoder encodeFloat:self.smoothing forKey:kSmoothing];
    VSRangeEncode(aCoder, self.deviceParameterRange, kDeviceParameterRange);
    VSRangeEncode(aCoder, self.parameterRange, kParameterRange);
    
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    
    VSDeviceParameterMapper *newMapper = nil;
    
    VSDevice *device = [aDecoder decodeObjectForKey:kDevice];
    NSString *deviceParameterIdentifier = [aDecoder decodeObjectForKey:kDeviceParameterIdentifier];
    float smoothing = [aDecoder decodeFloatForKey:kSmoothing];
    
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
        
        newMapper = [self initWithDeviceParameter:deviceParameter
                                    ofDevice:device
                        deviceParameterRange:parameterDeviceRange
                              parameterRange:parameterRange
                                andSmoothing:smoothing];
    }
    else{
        newMapper = [self initWithDeviceParameter:deviceParameter
                                    ofDevice:device
                                andSmoothing:smoothing];
    }
    
    return newMapper;
}

-(BOOL) currentDeviceParameterBoolValue{
    return [self.deviceParameter currentBOOLValue];
}

-(BOOL) activateDeviceParameter{
    if(!active)
        active = [self.device activateParameter:self.deviceParameter];
    
    return active;
}

-(BOOL) deactivateDeviceParameter{
    if(active)
        active= [self.device deactivateParameter:self.deviceParameter];
    
    return active;
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

    if (self.smoothing != SMOOTHINGRANGEMIN) {
        y = [self smoothValue:y withSmoothing:self.smoothing];
    }
    

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

- (float)smoothing
{
    return _smoothing;
}

- (void)setSmoothing:(float)smoothing
{    
    float k, deltaY, deltaX, d, x;
    
    //todo this is called every time. should be changed to a temporary property and only be altered when the somoothingslider is dragged
    VSRange inRange = [self.deviceParameter smoothingRange];
    VSRange outRange = VSMakeRange(SMOOTHINGRANGEMIN, SMOOTHINGRANGEMAX);
    
    x = smoothing - inRange.min;
    
    d = outRange.min;
    
    deltaY = outRange.max - outRange.min;
    deltaX = inRange.max - inRange.min;
    
    k = deltaY/deltaX;
    
    _smoothing = k * x + d;
}

@end
