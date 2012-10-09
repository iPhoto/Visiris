//
//  VSKeyFrame.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSBaseAnimationCurve.h"

/**
 * Keyframe of VSAnimation.
 *
 * A Keyframe describes a value for an parameter at a specific timestamp
 */
@interface VSKeyFrame : NSObject<NSCopying>


#pragma mark - Properties

/** Value of the paremeter the VSKeyFrame is set for */
@property id value;

/** Timestamp the VSKeyframe is set for. The timestamp is relative to the animation time. */
@property double timestamp;

/** Value of the keyFrame as NSString */
@property NSString *stringValue;

/** Value of the keyFrame as float */
@property float floatValue;

/** Value of the keyFrame as BOOL */ 
@property BOOL boolValue;

/** ID of the keyFrame. Unique for all keyFrames of one VSAnimation */
@property NSUInteger ID;

//todo edi
@property (strong) VSBaseAnimationCurve     *animationCurve;

#pragma mark - Init

/**
 * Inits the VSKeyFrame with the given value and timestamp.
 * @param aValue Value of the paramter the VSKeyFrame is connected to.
 * @param aTimestamp Timestamp the VSKeyframe is set for. The timestamp is relative to the animation time.
 * @param ID Unique id of the parameter
 * @return self
 */
-(id) initWithValue:(id) aValue forTimestamp:(double) aTimestamp andID:(NSUInteger) ID;

@end
