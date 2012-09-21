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
@property (strong,readonly) NSMutableArray *keyFrames;

/** Stores the device connected with the parameter if ther is one */
@property (strong) VSDeviceParameterMapper *deviceParameterMapper;

@property (strong) id defaultValue;

#pragma mark - Methods


-(float) floatValueForTimestamp:(double) timestamp;

-(NSString*) stringValueForTimestamp:(double) timestamp;

-(BOOL) boolValueForTimestamp:(double) timestamp;


/**
 * Adds a new Keyframe with the value for the timestamp
 * @param aValue Value of the new VSKeyFrame
 * @param aTimestamp Timestamp the keyFrame is created for. The timestamp is relative to the animation time.
 */
-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double) aTimestamp;


-(void) removeKeyFrame:(VSKeyFrame*) keyFrame;


-(void) changeKeyFrames:(VSKeyFrame*) keyFrame timestamp:(double) newTimestamp;

@end
