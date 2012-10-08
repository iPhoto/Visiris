//
//  VSOptionParameter.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.09.12.
//
//

#import "VSOptionParameter.h"

#import "VSAnimation.h"

#import "VSCoreServices.h"

@interface VSOptionParameter()

@property (strong) NSMutableDictionary *options;

@end

@implementation VSOptionParameter

#pragma mark - Init

-(id) initWithName:(NSString *)theName andID:(NSInteger)theID asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden rangeMinValue:(float)minRangeValue rangeMaxValue:(float)maxRangeValue{
    
    self = [super initWithName:theName
                         andID:theID
                        asType:aType
                   forDataType:aDataType
              withDefaultValue:theDefaultValue
                   orderNumber:aOrderNumber
                      editable:editable
                        hidden:hidden
                 rangeMinValue:minRangeValue
                 rangeMaxValue:maxRangeValue];
    
    if(self){
        _options = [[NSMutableDictionary alloc] init];
        if(!theDefaultValue){
            self.configuredDefaultValue = nil;
        }
    }
    
    return self;
}

-(id) initWithName:(NSString *)theName andID:(NSInteger)theID asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden{
    
    self = [super initWithName:theName
                         andID:theID
                        asType:aType
                   forDataType:aDataType
              withDefaultValue:theDefaultValue
                   orderNumber:aOrderNumber
                      editable:editable
                        hidden:hidden];
    
    if(self){
        _options = [[NSMutableDictionary alloc] init];
        if(!theDefaultValue){
            self.configuredDefaultValue = nil;
        }
    }
    
    return self;
}


#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *superCopy = [super copyWithZone:zone];
    
    VSOptionParameter *copy = nil;
    
    if(self.hasRange){
        copy = [[VSOptionParameter alloc] initWithName:superCopy.name
                                                 andID:superCopy.ID
                                                asType:superCopy.type
                                           forDataType:superCopy.dataType
                                      withDefaultValue:superCopy.defaultValue
                                           orderNumber:superCopy.orderNumber
                                              editable:superCopy.editable
                                                hidden:superCopy.hidden
                                         rangeMinValue:superCopy.range.min
                                         rangeMaxValue:superCopy.range.max];
    }
    else{
        copy = [[VSOptionParameter alloc] initWithName:superCopy.name
                                                 andID:superCopy.ID
                                                asType:superCopy.type
                                           forDataType:superCopy.dataType
                                      withDefaultValue:superCopy.defaultValue
                                           orderNumber:superCopy.orderNumber
                                              editable:superCopy.editable
                                                hidden:superCopy.hidden];
    }
    copy.animation = superCopy.animation;
    
    copy.options = [[NSMutableDictionary alloc] initWithDictionary:self.options copyItems:YES];
    
    
    return copy;
}

#pragma mark - Methods

-(void) addOptionWithKey:(id) key forValue:(id) value{
    
    if(!_options){
        _options = [[NSMutableDictionary alloc] init];
    }
    
    [_options setObject:value forKey:key];
    
    if(!self.configuredDefaultValue){
        self.configuredDefaultValue = [self.options objectForKey:key];
        self.defaultValue = self.configuredDefaultValue;
    }
}

#pragma mark Properties

-(void) setSelectedKey:(id)selectedKey{
    self.animation.defaultValue = [self.options objectForKey:selectedKey];
}

-(id) selectedKey{
    if(self.animation.keyFrames.count){
        return [[self.options allKeysForObject:[super currentValue]] objectAtIndex:0];
    }
    else{
        return [[self.options allKeysForObject:[super defaultValue]] objectAtIndex:0];
    }
}


@end
