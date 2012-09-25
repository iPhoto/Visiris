//
//  VSOptionParameter.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.09.12.
//
//

#import "VSParameter.h"

/**
 * Represents an Parameter for a VSTimelineObject where the value can be selected out of a list of predefined values
 *
 * Subclass of VSParameter
 */
@interface VSOptionParameter : VSParameter

/** Holds the possibel values the parameter's value can be set to */
@property (readonly,strong) NSMutableDictionary* options;

/** currently selected key of the options-Dictionary */
@property id selectedKey;

/**
 * Adds a new entry with the given key and value to the parameter's options-dictionary
 * @param key ID used as key for the new entry in the paramter's options-dictionary
 * @param value ID used as value for the new entry in the paramter's options-dictionary
 */
-(void) addOptionWithKey:(id) key forValue:(id) value;

@end
