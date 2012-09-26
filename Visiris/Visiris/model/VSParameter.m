//
//  VSParameter.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameter.h"

#import "VSAnimation.h"
#import "VSKeyFrame.h"

#import "VSCoreServices.h"

@interface VSParameter()



@end

@implementation VSParameter

@synthesize animation               = _animation;
@synthesize type                    = _type;
@synthesize dataType                = _dataType;
@synthesize name                    = _name;
@synthesize configuredDefaultValue  = _configuredDefaultValue;
@synthesize orderNumber             = _orderNumber;
@synthesize hasRange                = _hasRange;
@synthesize editable                = _editable;
@synthesize hidden                  = _hidden;
@synthesize rangeMaxValue           = _rangeMaxValue;
@synthesize rangeMinValue           = _rangeMinValue;
@synthesize currentValue            = _currentValue;
@synthesize ID                      = _ID;

#pragma mark - Init

-(id) initWithName:(NSString *)theName andID:(NSInteger) theID asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden rangeMinValue:(float)minRangeValue rangeMaxValue:(float)maxRangeValue{
    if(self = [super init]){
        self.name = theName;
        _ID = theID;
        self.type = aType;
        self.dataType = aDataType;
        self.hidden = hidden;
        self.editable = editable;
        self.orderNumber = aOrderNumber;
        
        [self initRangesWithMin:minRangeValue andMax:maxRangeValue];
        
        [self initDefaultValueWith:theDefaultValue];
        
        self.currentValue = [self.configuredDefaultValue copy];
        
        self.animation = [[VSAnimation alloc] init];
        self.animation.defaultValue = [self.configuredDefaultValue copy];
        
    }
    return self;
}

-(void) initRangesWithMin:(float) minRangeValue andMax:(float)maxRangeValue{
    if(maxRangeValue > minRangeValue){
        self.rangeMaxValue = maxRangeValue;
        self.rangeMinValue = minRangeValue;
        self.hasRange = YES;
    }
}

-(void) initDefaultValueWith:(id) defaultValue{
    if(!defaultValue){
        switch (self.dataType) {
            case VSParameterDataTypeString:
                self.configuredDefaultValue = [[NSString alloc] init];
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
        self.configuredDefaultValue = defaultValue;
        
    }
}


#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *copy = [[VSParameter allocWithZone:zone] initWithName:self.name
                                                                 andID:self.ID
                                                                asType:self.type
                                                           forDataType:self.dataType
                                                      withDefaultValue:self.configuredDefaultValue
                                                           orderNumber:self.orderNumber
                                                              editable:self.editable
                                                                hidden:self.hidden
                                                         rangeMinValue:self.rangeMinValue
                                                         rangeMaxValue:self.rangeMaxValue];
    
    
    copy.currentValue = [self.configuredDefaultValue copy];
    
    copy.animation = [self.animation copy];
    copy.animation.defaultValue = [self.configuredDefaultValue copy];
    
    return copy;
}

#pragma mark - Methods

-(id) valueForTimestamp:(double)timestamp{

    switch(self.dataType){
        case VSParameterDataTypeBool:{
            return [NSNumber numberWithBool:[self.animation copmuteBoolValueForTimestamp:timestamp]];
            break;
        }
        case VSParameterDataTypeFloat:{
            return [NSNumber numberWithFloat:[self.animation computeFloatValueForTimestamp:timestamp]];
            break;
        }
        case VSParameterDataTypeString:{
            NSString *result = [self.animation computStringValueForTimestamp:timestamp];
            return result;
            break;
        }
        default:{
            return [self.animation computStringValueForTimestamp:timestamp];
            break;
        }
    }

    return nil;
}

-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    VSKeyFrame* newKeyFrame = [self.animation addKeyFrameWithValue:aValue forTimestamp:aTimestamp];
    self.currentValue = newKeyFrame.value;
    
    return newKeyFrame;
}

-(void) updateCurrentValueForTimestamp:(double) aTimestamp{
    [self setValue:[self valueForTimestamp:aTimestamp] forKey:@"currentValue"];
}

-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] undoParametersDefaultValueChange:self.animation.defaultValue atUndoManager:undoManager];
    self.animation.defaultValue = oldValue;
}

-(NSString*) currentStringValue{
    if([_currentValue isKindOfClass:[NSString class]]){
        return (NSString*) _currentValue;
    }
    
    return @"";
}

-(BOOL) currentBoolValue{
    if([_currentValue isKindOfClass:[NSNumber class]]){
        return [_currentValue boolValue];
    }
    
    return false;
}

-(float) currentFloatValue{
    if([_currentValue isKindOfClass:[NSNumber class]]){
        return [_currentValue floatValue];
    }
    
    return 0.0f;
}

-(void) setValue:(id)value forKeyFrame:(VSKeyFrame *)keyFrame{
    keyFrame.value = value;
    self.currentValue = keyFrame.value;
}

-(void) changeKeyFrames:(VSKeyFrame *)keyFrame timestamp:(double)newTimestamp{
    [self.animation changeKeyFrames:keyFrame timestamp:newTimestamp];
}

-(void) removeKeyFrame:(VSKeyFrame *)keyFrameToRemove{
    [self.animation removeKeyFrame:keyFrameToRemove];
}

#pragma mark - Private Methods

/**
 * Checks if the given id is a valid NSNumber, and returns its float value
 * @param value id the float value will be returned of
 * @return Float value stored in the value if it is an valid NSNumber, nil oterhwise
 */
-(float) floatValueOf:(id) value{
    if([value isKindOfClass:[NSNumber class]]){
        return [((NSNumber *) value) floatValue];
    }
    else {
        return NO;
    }
}

/**
 * Checks if the given id is a valid NSNumber, and returns its bool value
 * @param value id the float value will be returned of
 * @return Bool value stored in the value if it is an valid NSNumber, nil oterhwise
 */
-(BOOL) booleanValueOf:(id) value{
    if([value isKindOfClass:[NSNumber class]]){
        return [((NSNumber *) value) boolValue];
    }
    else {
        return NO;
    }
}


/**
 * Checks if the given id is a valid NSString, and returns it
 * @param value id the float value will be returned of
 * @return Value as NSString if it is a valid NSString, nil otherwise
 */
-(NSString*) stringValueOf:(id) value{
    
    if([value isKindOfClass:[NSString class]]){
        return (NSString*) value;
    }
    else {
        return @"";
    }
}

/**
 * Changes the value of the given id if it's not in the parameter's range
 * @param value that will be checked if its in the parameters range
 * @reutrn Returns the corrected Value if it wasn't in the parameter's range and the unchanged value otherwise
 */
-(id) changeIfNotInRange:(id) value{
    if(self.dataType == VSParameterDataTypeFloat && self.hasRange){
        NSNumber *number = value;
        
        if([number floatValue] < self.rangeMinValue){
            return [NSNumber numberWithFloat:self.rangeMinValue];
        }
        
        if([number floatValue] > self.rangeMaxValue){
            return [NSNumber numberWithFloat:self.rangeMaxValue];
        }
    }
    
    return value;
}

#pragma mark - Properties

-(id) currentValue{
    return _currentValue;
}

-(void) setCurrentValue:(id)currentValue{
    _currentValue = currentValue;
}

-(id) defaultValue{
    return self.animation.defaultValue;
}

-(void) setDefaultValue:(id)defaultValue{
    self.animation.defaultValue = defaultValue;
    self.currentValue = self.animation.defaultValue;
}

-(float) defaultFloatValue{
    return [self floatValueOf:self.animation.defaultValue];
}

-(void) setDefaultFloatValue:(float) value{
    self.animation.defaultValue =  [self changeIfNotInRange:[NSNumber numberWithFloat:value]];
    self.currentValue = self.animation.defaultValue;
}

-(BOOL) defaultBoolValue{
    return [self booleanValueOf:self.animation.defaultValue];
}

-(void) setDefaultBoolValue:(BOOL) value{
    self.animation.defaultValue = [NSNumber numberWithBool:value];
    self.currentValue = self.animation.defaultValue;
}

-(NSString*) defaultStringValue{
    return [self stringValueOf:self.animation.defaultValue];
}

-(void) setDefaultStringValue:(NSString*) value{
    self.animation.defaultValue = [NSString stringWithString:value];
    self.currentValue = self.animation.defaultValue;
}


@end
