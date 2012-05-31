//
//  VSParameter.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSCoreServices.h"

@class VSAnimation;

/**
 * Parameter of VSTimelineObjectSource
 */
@interface VSParameter : NSObject<NSCopying>

/** Every parameter has its own animation. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added */
@property (strong) VSAnimation *animation;

/** Type of the parameter like defined in VSParameterTypes.h */
@property NSString *type;

/** Data type of the Parameter */
@property VSParameterDataType dataType;

/** Name of the parameter */
@property NSString* name;

/** Default value of the parameter as set in its description xml. */
@property id configuredDefaultValue;

/** Order of the parameter in the list of Parameters */
@property NSInteger orderNumber;

/** NO if no ranges are given, YES otherwise. */
@property BOOL hasRange;

/** Range of values valid for this parameters */
@property NSRange valueRange;

/** If true, the value of the paramter can be edited */
@property BOOL editable;

/** If YES the paramter is visible for the user */
@property BOOL hidden;


#pragma mark - Init

/**
 * Inits the VSParameter with the given data, inits its animation with a keyFRame holding the defaultValue at timestamp -1
 * @param theName Name of the parameter
 * @param aType Type of the parameter like defined in VSParameterTypes.h
 * @param aDataType VSParameterDataType defining the paramters DataType
 * @param theDefaultValue Default value of the parameter. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added.
 * @param aOrderNumber Defines where in the order of all parameters the parameter is shown.
 * @return self;
 */
-(id) initWithName:(NSString *) theName asType:(NSString*) aType forDataType:(VSParameterDataType) aDataType withDefaultValue:(id) theDefaultValue orderNumber:(NSInteger) aOrderNumber editable:(BOOL) editable hidden:(BOOL) hidden;

/**
 * Inits the VSParameter with the given data, inits its animation with a keyFRame holding the defaultValue at timestamp -1
 * @param theName Name of the parameter
 * @param aType Type of the parameter like defined in VSParameterTypes.h
 * @param aDataType VSParameterDataType defining the paramters DataType
 * @param theDefaultValue Default value of the parameter. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added.
 * @param aOrderNumber Defines where in the order of all parameters the parameter is shown.
 * @param aRange Range of values valid for this parameters
 * @return self;
 */
-(id) initWithName:(NSString *) theName asType:(NSString*) aType forDataType:(VSParameterDataType) aDataType withDefaultValue:(id) theDefaultValue orderNumber:(NSInteger) aOrderNumber editable:(BOOL) editable hidden:(BOOL) hidden validRang:(NSRange) aRange;


@end
