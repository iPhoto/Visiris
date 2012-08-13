//
//  VSAnimation.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSAnimation.h"

#import "VSKeyFrame.h"

#import "VSCoreServices.h"

@implementation VSAnimation

/** Timestamp of the default KeyFrame */

@synthesize keyFrames = _keyFrames;
@synthesize deviceParameterMapper = _deviceParameterMapper;

#pragma mark - Init

-(id) init{
    if(self = [super init]){
        self.keyFrames =[[NSMutableDictionary alloc] init];
    }
    
    return self;
}


#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSAnimation *copy = [[VSAnimation allocWithZone:zone] init];
    
    return copy;
}

#pragma mark - Methods

-(void) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    [self.keyFrames setObject:[[VSKeyFrame alloc] initWithValue:aValue forTimestamp:aTimestamp] forKey:[NSNumber numberWithDouble:aTimestamp]];
}

-(void) removeKeyFrameAt:(double)aTimestamp{
    [self.keyFrames removeObjectForKey:[NSNumber numberWithDouble:aTimestamp]];
}

-(void) setValue:(id)value forKeyFramAtTimestamp:(double)timestamp{
    VSKeyFrame *keyFrame = [self keyFrameForTimestamp:timestamp];
    
    if(keyFrame){
        keyFrame.value = value;
    }
}

-(id) valueForTimestamp:(double)timestamp{
    VSKeyFrame *keyFrame = [self keyFrameForTimestamp:timestamp];
    
    if(!keyFrame)
        return nil;
    
    return keyFrame.value;
}

-(VSKeyFrame*) keyFrameForTimestamp:(double)timestamp{
    return [self.keyFrames objectForKey:[NSNumber numberWithDouble:timestamp]];
}

@end
