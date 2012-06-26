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
@synthesize configuredDefaultValue = _configuredDefaultValue;
@synthesize orderNumber = _orderNumber;
@synthesize valueRange = _valueRange;
@synthesize hasRange = _hasRange;
@synthesize editable = _editable;
@synthesize hidden = _hidden;

#pragma mark - Init

-(id) initWithName:(NSString *)theName asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden{
    if(self = [super init]){
        self.configuredDefaultValue = theDefaultValue;
        self.name = theName;
        self.type = aType;
        self.dataType = aDataType;
        self.hidden = hidden;
        self.editable = editable;
        self.orderNumber = aOrderNumber;
        self.animation = [[VSAnimation alloc] initWithDefaultValue:self.configuredDefaultValue];
        
        self.hasRange = NO;
    }
    
    return self;
}

-(id) initWithName:(NSString *)theName asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden validRang:(NSRange)aRange{
    if(self = [self initWithName:theName asType:aType forDataType:aDataType withDefaultValue:theDefaultValue orderNumber:aOrderNumber editable:editable hidden:hidden]){
        self.valueRange = aRange;
        self.hasRange = YES;
        
    }
    
    return self;
}


#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *copy ;
    
    if(self.hasRange){
        copy = [[VSParameter allocWithZone:zone] initWithName:self.name asType:self.type forDataType:self.dataType withDefaultValue:self.configuredDefaultValue orderNumber:self.orderNumber editable:self.editable hidden:self.hidden validRang:self.valueRange];
    }
    else {
        copy = [[VSParameter allocWithZone:zone] initWithName:self.name asType:self.type forDataType:self.dataType withDefaultValue:self.configuredDefaultValue orderNumber:self.orderNumber editable:self.editable hidden:self.hidden];
    }
    
    copy.animation = [self.animation copy];
    
    return copy;
}

-(NSString*) description{
    return [NSString stringWithFormat:@"OrderNumber: %d",self.orderNumber];
}



@end
