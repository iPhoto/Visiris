//
//  VSOptionParameter.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.09.12.
//
//

#import "VSParameter.h"

@interface VSOptionParameter : VSParameter

@property (readonly) NSMutableDictionary* options;

@property id selectedKey;

-(void) addOptionWithKey:(id) key forValue:(id) value;

@end
