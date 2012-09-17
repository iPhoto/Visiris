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

@interface VSParameter()

@property id currentValue;

@end

@implementation VSParameter

#define DEFAULT_KEY_FRAME_TIMESTAMP -1

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
                    self.configuredDefaultValue = [[NSString alloc] init];
                    self.configuredDefaultValue = @"Hallo";
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
        
        self.currentValue = self.configuredDefaultValue;
        self.animation = [[VSAnimation alloc] init];
        [self.animation addKeyFrameWithValue:self.configuredDefaultValue forTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
    }
    return self;
}



#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *copy = [[VSParameter allocWithZone:zone] initWithName:self.name
                                                                asType:self.type
                                                           forDataType:self.dataType
                                                      withDefaultValue:self.configuredDefaultValue
                                                           orderNumber:self.orderNumber
                                                              editable:self.editable
                                                                hidden:self.hidden
                                                         rangeMinValue:self.rangeMinValue
                                                         rangeMaxValue:self.rangeMaxValue];
    
    
    copy.animation = [self.animation copy];
    
    [copy.animation addKeyFrameWithValue:copy.configuredDefaultValue forTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
    
    return copy;
}
//
//-(NSString*) description{
//    return [NSString stringWithFormat:@"Name: %@",self.name];
//}

-(id) valueForTimestamp:(double)timestamp{

    switch(self.dataType){
        case VSParameterDataTypeBool:{
            return [self.animation valueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
            break;
        }
        case VSParameterDataTypeFloat:{
            return [NSNumber numberWithFloat:[self.animation floatValueForTimestamp:timestamp]];
            break;
        }
        case VSParameterDataTypeString:{
            return [self.animation valueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
            break;
        }
    }

    return nil;
}


-(VSKeyFrame*) keyFrameForTimestamp:(double)timestamp{
    return [self.animation keyFrameForTimestamp:timestamp];
}

-(void) updateCurrentValueForTimestamp:(double) aTimestamp{
    id value = [self valueForTimestamp:aTimestamp];
    if([self.type isEqualToString:VSParameterKeyPositionX]){
        DDLogInfo(@"currentValue: %@ for %f",value, aTimestamp);
    }
    [self setValue:value forKey:@"currentValue"];
}

//TODO: error-handlin
-(float) floatValueForTimestamp:(double)timestamp{
    return[self floatValueOf:[self valueForTimestamp:timestamp]];
}

-(NSString*) stringValueForTimestamp:(double)timestamp{
    return[self stringValueOf:[self valueForTimestamp:timestamp]];
}

-(BOOL) boolValueForTimestamp:(double)timestamp{
    return[self booleanValueOf:[self valueForTimestamp:timestamp]];
}

-(float) defaultFloatValue{
    return [self floatValueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
}

-(NSString*)defaultStringValue{
    return [self stringValueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
}

-(BOOL) defaultBoolValue{
    return [self boolValueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
}

-(void) setValue:(id)value forKeyFramAtTimestamp:(double)timestamp{
    value = [self changeIfNotInRange:value];
    [self.animation setValue:value forKeyFramAtTimestamp:timestamp];
}

-(void) setDefaultBoolValue:(BOOL)value{
    [self setDefaultValue:[NSNumber numberWithBool:value]];
}

-(void) setDefaultStringValue:(NSString *)value{
    [self setDefaultValue:value];
}

-(void) setDefaultFloatValue:(float)value{
    NSNumber *newNumber = [NSNumber numberWithFloat:value];
    [self setDefaultValue:newNumber];
}

-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    VSKeyFrame* newKeyFrame = [self.animation addKeyFrameWithValue:aValue forTimestamp:aTimestamp];
    DDLogInfo(@"in param: %@ %@",self, self.animation);
    self.test++;
    return newKeyFrame;
}

-(void) removeKeyFrameAt:(double)aTimestamp{
    [self.animation removeKeyFrameAt:aTimestamp];
}

-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] undoParametersDefaultValueChange:self.defaultValue atUndoManager:undoManager];
    self.defaultValue = oldValue;
}

-(NSString*) currentStringValue{
    if([_currentValue isKindOfClass:[NSString class]]){
        return (NSString*) _currentValue;
    }
    
    return @"";
}

-(bool) currentBoolValue{
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

-(id) defaultValue{
    
    return [self valueForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
}

-(void) setDefaultValue:(id)defaultValue{
    [self willChangeValueForKey:@"defaultValue"];
    [self setValue:defaultValue forKeyFramAtTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
    [self didChangeValueForKey:@"defaultValue"];
}

-(NSArray*) editableKeyFrames{
    if(self.animation.keyFrames.count == 1){
        return [[NSArray alloc] init];
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithArray:[self.animation.keyFrames allValues]];;
    [result removeObject:self.defaultKeyFrame];
    return [NSArray arrayWithArray:result];
}

-(VSKeyFrame*) defaultKeyFrame{
    return [self.animation keyFrameForTimestamp:DEFAULT_KEY_FRAME_TIMESTAMP];
}

-(id) currentValue{
    return _currentValue;
}

-(void) setCurrentValue:(id)currentValue{
    _currentValue = currentValue;
}


@end
