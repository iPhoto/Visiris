//
//  VSAnimation.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAnimation.h"

#import "VSKeyFrame.h"

#import "VSCoreServices.h"

@implementation VSAnimation

/** Timestamp of the default KeyFrame */
const int defaultKeyFrameTimestamp = -1;

@synthesize keyFrames = _keyFrames;
@synthesize deviceParameterMapper = _deviceParameterMapper;
@synthesize defaultValue = _defaultValue;

#pragma mark - Init

-(id) init{
    if(self = [super init]){
        self.keyFrames =[[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(id) initWithDefaultValue:(id)theDefaultValue{
    if(self = [self init]){
        [self addKeyFrameWithValue:theDefaultValue forTimestamp:defaultKeyFrameTimestamp];
    }
    
    return self;
}


#pragma mark - Methods




-(id) valueForTimestamp:(double)timestamp{
    VSKeyFrame *keyFrame = [self keyFrameForTimestamp:timestamp];
    
    if(!keyFrame)
        return nil;
    
    return keyFrame.value;
}


-(VSKeyFrame*) keyFrameForTimestamp:(double)timestamp{
    return [self.keyFrames objectForKey:[NSNumber numberWithDouble:timestamp]];
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
    return [self floatValueForTimestamp:defaultKeyFrameTimestamp];
}

-(NSString*)defaultStringValue{
    return [self stringValueForTimestamp:defaultKeyFrameTimestamp];
}

-(BOOL) defaultBoolValue{
    return [self boolValueForTimestamp:defaultKeyFrameTimestamp];
}

-(void) setValue:(id)value forKeyFramAtTimestamp:(double)timestamp{
    VSKeyFrame *keyFrame = [self keyFrameForTimestamp:timestamp];
    
    if(keyFrame){
        keyFrame.value = value;
    }
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


-(void) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    [self.keyFrames setObject:[[VSKeyFrame alloc] initWithValue:aValue forTimestamp:aTimestamp] forKey:[NSNumber numberWithDouble:aTimestamp]];
}

-(void) removeKeyFrameAt:(double)aTimestamp{
    [self.keyFrames removeObjectForKey:[NSNumber numberWithDouble:aTimestamp]];
}

-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager *)undoManager{
    [[undoManager prepareWithInvocationTarget:self] undoParametersDefaultValueChange:self.defaultValue atUndoManager:undoManager];
    self.defaultValue = oldValue; 
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
        return nil;
    }
}


#pragma mark - Properties

-(id) defaultValue{
    
    return [self valueForTimestamp:defaultKeyFrameTimestamp];
}

-(void) setDefaultValue:(id)defaultValue{
    [self willChangeValueForKey:@"defaultValue"];
    [self setValue:defaultValue forKeyFramAtTimestamp:defaultKeyFrameTimestamp];
    [self didChangeValueForKey:@"defaultValue"];
}

@end
