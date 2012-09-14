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
@class VSKeyFrame;

/**
 * Parameter of VSTimelineObjectSource
 */
@interface VSParameter : NSObject<NSCopying>

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

/** Minimal valid value of the parameter */
@property float rangeMinValue;

/** Maximal valid value of the parameter */
@property float rangeMaxValue;

/** If true, the value of the paramter can be edited */
@property BOOL editable;

/** If YES the paramter is visible for the user */
@property BOOL hidden;

/** Every parameter has its own animation. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added */
@property (strong) VSAnimation *animation;

@property id defaultValue;

@property (readonly) NSArray *editableKeyFrames;

@property (readonly) VSKeyFrame *defaultKeyFrame;

#pragma mark - Init


/**
 * Inits the VSParameter with the given data, inits its animation with a keyFRame holding the defaultValue at timestamp -1
 * @param theName Name of the parameter
 * @param aType Type of the parameter like defined in VSParameterTypes.h
 * @param aDataType VSParameterDataType defining the paramters DataType
 * @param theDefaultValue Default value of the parameter. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added.
 * @param aOrderNumber Defines where in the order of all parameters the parameter is shown.
 * @param minRangeValue Minimal Value of the parameter
 * @param maxRangeValue Maximal Value of the parameter
 * @param editable Indicates wheter the user is allowed to edit the parameter or not.
 * @param hidden Indicates wheter the parameter is shown in the gui or not.
 * @return self;
 */
-(id) initWithName:(NSString *) theName asType:(NSString*) aType forDataType:(VSParameterDataType) aDataType withDefaultValue:(id) theDefaultValue orderNumber:(NSInteger) aOrderNumber editable:(BOOL) editable hidden:(BOOL) hidden rangeMinValue:(float) minRangeValue rangeMaxValue:(float) maxRangeValue;


#pragma mark - Methods
/**
 * Returns the value of the animation at the current timestamp.
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp. If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(id) valueForTimestamp:(double) timestamp;

/**
 * Returns the key frame of the animation at the current timestamp.
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the keyframe will returned for. The timestamp is relative to the animation time.
 * @return The keyframe, if a keyfram was set for this timestamp, nil otherwise
 */
-(VSKeyFrame*) keyFrameForTimestamp:(double) timestamp;

///**
// * Returns the value of the animation at the current timestamp as float
// *
// * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
// * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// */
//-(float) floatValueForTimestamp:(double) timestamp;
//
///**
// * Returns the value of the animation at the current timestamp as NSString
// *
// * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
// * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// */
//-(NSString*) stringValueForTimestamp:(double) timestamp;
//
///**
// * Returns the value of the animation at the current timestamp as boolean
// *
// * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
// * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
// */
//-(BOOL) boolValueForTimestamp:(double) timestamp;

/**
 * Returns the value stored in the keyframe with timestamp -1 as float
 * @return The value stored in the keyframe with timestamp -1
 */
-(float) defaultFloatValue;

/**
 * Returns the value stored in the keyframe with timestamp -1 as NSString
 * @return The value stored in the keyframe with timestamp -1 as NSString
 */
-(NSString*) defaultStringValue;

/**
 * Returns the value stored in the keyframe with timestamp -1 as BOOL
 * @return The value stored in the keyframe with timestamp -1 as BOOL
 */
-(BOOL) defaultBoolValue;


/**
 * Sets the NSString value for the keyframe with the timestamp -1
 * @param value Value set as DefaultValue
 */
-(void) setDefaultStringValue:(NSString*) value;

/**
 * Sets the Boolean value for the keyframe with the timestamp -1
 * @param value Value set as DefaultValue
 */
-(void) setDefaultBoolValue:(BOOL) value;

/**
 * Sets the float value for the keyframe with the timestamp -1
 * @param value Value set as DefaultValue
 */
-(void) setDefaultFloatValue:(float) value;

/**
 * Adds a new Keyframe with the value for the timestamp
 * @param aValue Value of the new VSKeyFrame
 * @param aTimestamp Timestamp the keyFrame is created for. The timestamp is relative to the animation time.
 */
-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double) aTimestamp;

/**
 * Removes the keyFrame with the aTimestamp.
 * @param aTimestamp The timestamp the keyfram is deleted for.
 */
-(void) removeKeyFrameAt:(double) aTimestamp;

/**
 * Set as selector for undoing changes of the parameter's default value
 * @param oldValue DefaultValue of the parameter before the change.
 * @param undoManager NSUndoManager the change of the defaultValue is registrated at.
 */
-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager*) undoManager;


@end
