//
//  VSKeyFrame.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSKeyFrame.h"

#import "VSAnimationCurve.h"
#import "VSLinearAnimation.h"
#import "VSEaseInAnimation.h"
#import "VSEaseOutAnimation.h"
#import "VSEaseInOutAnimation.h"

@implementation VSKeyFrame
@synthesize value = _value;
@synthesize timestamp = _timestamp;

#pragma mark - Init

-(id) initWithValue:(id)aValue forTimestamp:(double)aTimestamp andID:(NSUInteger)ID{
    if(self = [self init]){
        self.value = aValue;
        self.timestamp = aTimestamp;
        self.ID = ID;
        self.animationCurve = [[VSLinearAnimation alloc] init];
    }
    
    return self;
}

#pragma mark -NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSKeyFrame *copy = [[VSKeyFrame alloc] initWithValue:self.value forTimestamp:self.timestamp andID:self.ID];
    
    return copy;
}

#pragma mark - NSObject

-(NSString*) description{
    return [NSString stringWithFormat:@"Timestamp: %f, Value: %@",self.timestamp, self.value];
}

#pragma mark - Properties

-(NSString*) stringValue{
    if([self.value isKindOfClass:[NSString class]]){
        return (NSString*) self.value;
    }
    
    if([self.value respondsToSelector:@selector(stringValue)]){
        return [self.value stringValue];
    }
    
    return @"";
}

-(void) setStringValue:(NSString *)stringValue{
    self.value = stringValue;
}

-(float) floatValue{
    if([self.value isKindOfClass:[NSNumber class]]){
        return [self.value floatValue];
    }
    
    return 0.0;
}

-(void) setFloatValue:(float)floatValue{
    self.value = [NSNumber numberWithFloat:floatValue];
}

-(BOOL) boolValue{
    if([self.value isKindOfClass:[NSNumber class]]){
        return [self.value boolValue];
    }
    
    return NO;
}

-(void) setBoolValue:(BOOL)boolValue{
    self.value = [NSNumber numberWithBool:boolValue];
}

@end
