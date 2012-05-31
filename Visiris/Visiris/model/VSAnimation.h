//
//  VSAnimation.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSDeviceParameterMapper;
@class VSKeyFrame;

/**
 * VSAnimation stores the values for an VSParameter in VSKeyFrames.
 *
 * Every VSParameter has its own VSAnimation object. As soon as an VSTimelineObject is added a animation for every parameter is created and a keyframe with the default-value is set.
 */
@interface VSAnimation : NSObject

/** List of all VSKeyFrames of the animation */
@property (strong) NSMutableArray *keyFrames;

/** Stores the device connected with the parameter if ther is one */
@property (strong) VSDeviceParameterMapper *deviceParameterMapper;


@property id defaultValue;


#pragma mark - Init

/**
 * Creates a keyframe for timestamp -1 with the given value.
 * @param theDefaultValue Value a keyfram with timestamp -1 will be created for
 * @return self
 */
-(id) initWithDefaultValue:(NSData*) theDefaultValue;


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

/**
 * Returns the value of the animation at the current timestamp as float
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(float) floatValueForTimestamp:(double) timestamp;

/**
 * Returns the value of the animation at the current timestamp as NSString
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(NSString*) stringValueForTimestamp:(double) timestamp;

/**
 * Returns the value of the animation at the current timestamp as boolean
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp.  If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(BOOL) boolValueForTimestamp:(double) timestamp;

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
 */
-(void) setDefaultStringValue:(NSString*) value;

/**
 * Sets the Boolean value for the keyframe with the timestamp -1
 */
-(void) setDefaultBoolValue:(BOOL) value;

/**
 * Sets the float value for the keyframe with the timestamp -1
 */
-(void) setDefaultFloatValue:(float) value;


/**
 * Sets the value of the key frame at the given timestamp
 * @param value Value set for key frame at the timestamp
 * @param timestamp Timestamp of the key frame
 */
-(void) setValue:(id) value forKeyFramAtTimestamp:(double) timestamp;


/**
 * Adds a new Keyframe with the value for the timestamp
 * @param aValue Value of the new VSKeyFrame
 * @param aTimestamp Timestamp the keyFrame is created for. The timestamp is relative to the animation time.
 */
-(void) addKeyFrameWithValue:(id) aValue forTimestamp:(double) aTimestamp;

/**
 * Removes the keyFrame with the aTimestamp.
 * @param aTimestamp The timestamp the keyfram is deleted for.
 * @return YES if the keyFrame was removed successfully, NO otherwise
 */
-(BOOL) removeKeyFrameAt:(double) aTimestamp;

/**
 * Set as selector for undoing changes of the parameter's default value 
 * @oldValue DefaultValue of the parameter before the change.
 */
-(void) undoParametersDefaultValueChange:(id) oldValue atUndoManager:(NSUndoManager*) undoManager;

@end
