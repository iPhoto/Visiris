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

@interface VSAnimation()

@property NSArray *sortedKeyFrameTimestamps;

@end

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

-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    VSKeyFrame* newKeyFrame = [[VSKeyFrame alloc] initWithValue:aValue forTimestamp:aTimestamp];
    [self.keyFrames setObject:newKeyFrame forKey:[NSNumber numberWithDouble:aTimestamp]];
    
    self.sortedKeyFrameTimestamps = [self.keyFrames allKeys];
    
    self.sortedKeyFrameTimestamps = [self.sortedKeyFrameTimestamps sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if([obj1 doubleValue] > [obj2 doubleValue]){
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    return newKeyFrame;
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

-(float) floatValueForTimestamp:(double)timestamp{
    
    if(self.keyFrames.count == 1){
        return ((VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:0]]).floatValue;
    }
    else{
        NSUInteger nexKeyFrameIndex = [self.sortedKeyFrameTimestamps indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj doubleValue] > timestamp){
                return YES;
            }
            return NO;
        }];
    
        if(nexKeyFrameIndex == NSNotFound){
            return ((VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps lastObject]]).floatValue;
        }
        else{
            VSKeyFrame *keyframe1 = (VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:nexKeyFrameIndex-1]];
            
            VSKeyFrame *keyframe2 = (VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:nexKeyFrameIndex]];
            
            return ((keyframe2.timestamp - keyframe1.timestamp) / (keyframe2.floatValue - keyframe1.floatValue)) * timestamp + keyframe1.floatValue;
            
        }
    }
}

-(VSKeyFrame*) keyFrameForTimestamp:(double)timestamp{
    return [self.keyFrames objectForKey:[NSNumber numberWithDouble:timestamp]];
}

@end
