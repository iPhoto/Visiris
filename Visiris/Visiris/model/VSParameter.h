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
@class VSDeviceParameter;
@class VSDevice;
@class VSDeviceParameterMapper;

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

@property VSRange range;

/** If true, the value of the paramter can be edited */
@property BOOL editable;

/** If YES the paramter is visible for the user */
@property BOOL hidden;

/** Every parameter has its own animation. As soon as an parameter is initialized, a new Keyframe for the timestamp -1 with its default value is added */
@property (strong) VSAnimation *animation;

/** current value of the parameter according to it's animation and a timestamp given when updateCurrentValue is called */
@property (readonly) id currentValue;

/** default value of the parameter which is the the same as the configuredDefaultValue when the parameter is created. The default value is changed while no keyFrame is added to the parameter's animation */
@property id defaultValue;

/** the paramter's ID */
@property (readonly) NSUInteger ID;

@property BOOL connectedWithDeviceParameter;

@property (weak,readonly) VSDeviceParameter *deviceParamterConnectedWith;

@property (weak,readonly) VSDevice *deviceConnectedWith;

@property VSDeviceParameterMapper *deviceParameterMapper;

#pragma mark - Init


/**
 * Inits the VSParameter with the given data
 *
 * @param theName Name of the parameter
 * @param theID Unique ID of the parameter
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
-(id) initWithName:(NSString *) theName andID:(NSInteger) theID asType:(NSString*) aType forDataType:(VSParameterDataType) aDataType withDefaultValue:(id) theDefaultValue orderNumber:(NSInteger) aOrderNumber editable:(BOOL) editable hidden:(BOOL) hidden rangeMinValue:(float) minRangeValue rangeMaxValue:(float) maxRangeValue;

-(id) initWithName:(NSString *)theName andID:(NSInteger) theID asType:(NSString *)aType forDataType:(VSParameterDataType)aDataType withDefaultValue:(id)theDefaultValue orderNumber:(NSInteger)aOrderNumber editable:(BOOL)editable hidden:(BOOL)hidden;


#pragma mark - Methods
/**
 * Returns the value of the animation at the current timestamp.
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp. If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(id) valueForTimestamp:(double) timestamp;


#pragma mark Default Values

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
 * Set as selector for undoing changes of the parameter's default value
 * @param oldValue DefaultValue of the parameter before the change.
 * @param undoManager NSUndoManager the change of the defaultValue is registrated at.
 */
-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager*) undoManager;

/**
 * Updates the parameter's currentValue-Property for the given timestamp.
 *
 * Tells it's animation to compute the parameters value for the timestamp
 * @param aTimestamp Timestamp the value is computed for
 */
-(void) updateCurrentValueForTimestamp:(double) aTimestamp;

/**
 * Current Value as NSString
 * @return The currentValue of the Parameter as NSString
 */
-(NSString*) currentStringValue;

/**
 * Current Value as BOOL
 * @return The currentValue of the Parameter as BOOL
 */
-(BOOL) currentBoolValue;

/**
 * Current Value as float
 * @return The currentValue of the Parameter as float
 */
-(float) currentFloatValue;

/**
 * Changes the keyFrames value and sets it as currentValue of the parameter.
 * @param value Value the given keyFrame's value will be changed
 * @param keyFrame VSKeyFrame the value will be changed of
 */
-(void) setValue:(id)value forKeyFrame:(VSKeyFrame*) keyFrame;

/**
 * Changes the timestamp of the given keyFrame
 * @param keyFrame VSKeyFrame the timestamp will be changed of
 * @param newTimestamp Timestamp the given keyFrame's timestamp will be set to
 */
-(void) changeKeyFrames:(VSKeyFrame*) keyFrame timestamp:(double) newTimestamp;

/**
 * Removes the given VSKeyFrame from the parameter's animation
 * @param keyFrameToRemove VSKeyFrame which will be removed from the parameter's animation
 */
-(void) removeKeyFrame:(VSKeyFrame*) keyFrameToRemove;

-(BOOL) connectWithDeviceParameter:(VSDeviceParameter*) deviceParameter ofDevice:(VSDevice*) device deviceParameterRange:(VSRange)deviceParameterRange andParameterRange:(VSRange)parameterRange;

-(void) disconnectFromDevice;

@end
