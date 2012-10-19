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
@interface VSAnimation : NSObject<NSCopying, NSCoding>

/** List of all VSKeyFrames of the animation */
@property (strong,readonly) NSMutableArray *keyFrames;

/** Stores the device connected with the parameter if ther is one */
@property (strong) VSDeviceParameterMapper *deviceParameterMapper;

/** Value of the parameter the VSAnimatin is connected with when no keyFrame was set yet */
@property (strong) id defaultValue;

-(id) initWithDefaultValue:(id)defaultValue;

#pragma mark - Methods

/**
 * Computes the float-value for the given timestamp of the animation according to its keyFrames 
 * @param timestamp Timestamp the value is computed for
 * @return The float-value for the given timestamp the animation has according to its keyFrames
 */
-(float) computeFloatValueForTimestamp:(double) timestamp;

/**
 * Computes the NSString-value for the given timestamp of the animation according to its keyFrames
 * @param timestamp Timestamp the value is computed for
 * @return The NSString-value for the given timestamp the animation has according to its keyFrames
 */
-(NSString*) computeStringValueForTimestamp:(double) timestamp;

/**
 * Computes the BOOL-value for the given timestamp of the animation according to its keyFrames
 * @param timestamp Timestamp the value is computed for
 * @return The BOOL-value for the given timestamp the animation has according to its keyFrames
 */
-(BOOL) copmuteBoolValueForTimestamp:(double) timestamp;


/**
 * Adds a new Keyframe with the value for the timestamp
 * @param aValue Value of the new VSKeyFrame
 * @param aTimestamp Timestamp the keyFrame is created for. The timestamp is relative to the animation time.
 */
-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double) aTimestamp;

/**
 * Removes the given keyFrame from the animation
 * @param keyFrame VSKeyFrame which will be removed
 */
-(void) removeKeyFrame:(VSKeyFrame*) keyFrame;

/**
 * Changes the timestamp of the given keyFrame
 * @param keyFrame VSKeyFrame the timestamp is changed of
 * @param newTimestamp Double-value the timestamp of the given keyFrame is set to
 */
-(void) changeKeyFrames:(VSKeyFrame*) keyFrame timestamp:(double) newTimestamp;

@end
