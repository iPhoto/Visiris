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
@interface VSAnimation : NSObject<NSCopying>

/** List of all VSKeyFrames of the animation */
@property (strong) NSMutableDictionary *keyFrames;

/** Stores the device connected with the parameter if ther is one */
@property (strong) VSDeviceParameterMapper *deviceParameterMapper;


#pragma mark - Methods
/**
 * Returns the value of the animation at the current timestamp.
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the value will returned for. The timestamp is relative to the animation time.
 * @return The value of the parameter the animation is connected with for the given timestamp. If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 */
-(id) valueForTimestamp:(double) timestamp;

-(float) floatValueForTimestamp:(double) timestamp;

/**
 * Returns the key frame of the animation at the current timestamp.
 *
 * If an VSDeviceParameterMapper is set, it returns the current Device value mapped to the parameter values
 * @param timestamp Timestamp the keyframe will returned for. The timestamp is relative to the animation time.
 * @return The keyframe, if a keyfram was set for this timestamp, nil otherwise
 */
-(VSKeyFrame*) keyFrameForTimestamp:(double) timestamp;


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
-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double) aTimestamp;

/**
 * Removes the keyFrame with the aTimestamp.
 * @param aTimestamp The timestamp the keyfram is deleted for.
 */
-(void) removeKeyFrameAt:(double) aTimestamp;

@end
