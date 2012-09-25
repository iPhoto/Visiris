//
//  VSKeyFrame.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Keyframe of VSAnimation.
 *
 * A Keyframe describes a value for an parameter at a specific timestamp
 */
@interface VSKeyFrame : NSObject


#pragma mark - Properties

/** Value of the paremeter the VSKeyFrame is set for */
@property id value;

/** Timestamp the VSKeyframe is set for. The timestamp is relative to the animation time. */
@property double timestamp;

@property NSString *stringValue;

@property float floatValue;

@property BOOL boolValue;

@property NSUInteger ID;

#pragma mark - Init

/**
 * Inits the VSKeyFrame with the given value and timestamp.
 * @param aValue Value of the paramter the VSKeyFrame is connected to.
 * @param aTimestamp Timestamp the VSKeyframe is set for. The timestamp is relative to the animation time.
 * @return self
 */
-(id) initWithValue:(NSData*) aValue forTimestamp:(double) aTimestamp andID:(NSUInteger) ID;

@end
