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
@property NSMutableDictionary *options;
@end

@implementation VSOptionParameter

-(id) initWithName:(NSString *)theName asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden rangeMinValue:(float)minRangeValue rangeMaxValue:(float)maxRangeValue{
    
    self = [super initWithName:theName
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


#pragma mark - VSCopying
-(id) copyWithZone:(NSZone *)zone{
    
    VSParameter *superCopy = [super copyWithZone:zone];
    
    VSOptionParameter *copy = [[VSOptionParameter alloc] initWithName:superCopy.name
                                                               asType:superCopy.type
                                                          forDataType:superCopy.dataType
                                                     withDefaultValue:superCopy.defaultValue
                                                          orderNumber:superCopy.orderNumber
                                                             editable:superCopy.editable
                                                               hidden:superCopy.hidden
                                                        rangeMinValue:superCopy.rangeMinValue
                                                        rangeMaxValue:superCopy.rangeMaxValue];
    copy.animation = superCopy.animation;
    
    copy.options = [[NSMutableDictionary alloc] initWithDictionary:self.options copyItems:YES];
    
    return copy;
}

-(void) addOptionWithKey:(id) key forValue:(id) value{
    
    if(!_options){
        _options = [[NSMutableDictionary alloc] init];
    }
    
    [_options setObject:value forKey:key];
    
    if(!self.configuredDefaultValue){
        self.configuredDefaultValue = [self.options objectForKey:key];
    }
}

#pragma mark Properties

-(void) setSelectedKey:(id)selectedKey{
    [super setDefaultValue:[self.options objectForKey:selectedKey]];
}

-(id) selectedKey{
    return [[self.options allKeysForObject:[super defaultValue]] objectAtIndex:0];
}

@end
