//
//  VSParameter.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameter.h"

#import "VSAnimation.h"

#import "VSCoreServices.h"
@implementation VSParameter
@synthesize animation = _animation;
@synthesize type = _type;
@synthesize dataType = _dataType;
@synthesize name = _name;
@synthesize configuredDefaultValue  = _configuredDefaultValue;
@synthesize orderNumber             = _orderNumber;
@synthesize hasRange = _hasRange;
@synthesize editable = _editable;
@synthesize hidden = _hidden;
@synthesize rangeMaxValue = _rangeMaxValue;
@synthesize rangeMinValue = _rangeMinValue;

#pragma mark - Init

-(id) initWithName:(NSString *)theName asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden rangeMinValue:(float)minRangeValue rangeMaxValue:(float)maxRangeValue{
    if(self = [super init]){
        self.name = theName;
        self.type = aType;
        self.dataType = aDataType;
        self.hidden = hidden;
        self.editable = editable;
        self.orderNumber = aOrderNumber;
        
        
        if(maxRangeValue > minRangeValue){
            self.rangeMaxValue = maxRangeValue;
            self.rangeMinValue = minRangeValue;
            self.hasRange = YES;
        }
        
        if(!theDefaultValue){
            switch (self.dataType) {
                case VSParameterDataTypeString:
                    self.configuredDefaultValue = @"";
                    break;
                case VSParameterDataTypeFloat:
                    if(self.hasRange){
                        self.configuredDefaultValue = [NSNumber numberWithFloat:self.rangeMinValue];
                    }
                    else {
                        self.configuredDefaultValue = [NSNumber numberWithFloat:0];
                    }
                    break;
                case VSParameterDataTypeBool:
                    self.configuredDefaultValue = [NSNumber numberWithBool:NO];
            }
        }
        else {
            self.configuredDefaultValue = theDefaultValue;
            
        }
        self.animation = [[VSAnimation alloc] initWithDefaultValue:self.configuredDefaultValue];
    }
    return self;
}



#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *copy = [[VSParameter allocWithZone:zone] initWithName:self.name asType:self.type forDataType:self.dataType withDefaultValue:self.configuredDefaultValue orderNumber:self.orderNumber editable:self.editable hidden:self.hidden rangeMinValue:self.rangeMinValue rangeMaxValue:self.rangeMaxValue];
    
    
    copy.animation = [self.animation copy];
    
    return copy;
}

-(NSString*) description{
    return [NSString stringWithFormat:@"Name: %@",self.name];
}


@end
