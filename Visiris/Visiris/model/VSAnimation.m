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

@end

@implementation VSAnimation

/** Timestamp of the default KeyFrame */

@synthesize keyFrames = _keyFrames;
@synthesize deviceParameterMapper = _deviceParameterMapper;
@synthesize sortedKeyFrameTimestamps = _sortedKeyFrameTimestamps;
#pragma mark - Init

-(id) init{
    if(self = [super init]){
        self.keyFrames =[[NSMutableDictionary alloc] init];
        _sortedKeyFrameTimestamps = [[NSMutableArray alloc]init];
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
    
    NSNumber *key = [NSNumber numberWithDouble:aTimestamp];
    [self.keyFrames setObject:newKeyFrame forKey:key];

    
    NSUInteger newIndex = [self.sortedKeyFrameTimestamps indexOfObject:key inSortedRange:NSMakeRange(0, self.sortedKeyFrameTimestamps.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([obj1 doubleValue] > [obj2 doubleValue]){
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    if(newIndex == NSNotFound){
        newIndex = self.sortedKeyFrameTimestamps.count;
    }
    
    [self.sortedKeyFrameTimestamps insertObject:key atIndex:newIndex];

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
            
            float result = ((keyframe2.floatValue - keyframe1.floatValue)  / (keyframe2.timestamp - keyframe1.timestamp) ) * (timestamp-keyframe1.timestamp) + keyframe1.floatValue;
            DDLogInfo(@"%f %f %f",(keyframe2.timestamp - keyframe1.timestamp),(keyframe2.floatValue - keyframe1.floatValue),(timestamp-keyframe1.timestamp));
            DDLogInfo(@"key1: %@ key2: %@",keyframe1,keyframe2);
            DDLogInfo(@"result: %f",result);
            DDLogInfo(@"%f %f",keyframe2.floatValue, keyframe1.floatValue);
            DDLogInfo(@"timestamp: %f",timestamp);
            
            return result;
            
        }
    }
}

-(VSKeyFrame*) keyFrameForTimestamp:(double)timestamp{
    return [self.keyFrames objectForKey:[NSNumber numberWithDouble:timestamp]];
}

#pragma mark - Properties

-(NSMutableArray*) sortedKeyFrameTimestamps
{
    return [self mutableArrayValueForKey:@"sortedKeyFrameTimestamps"];
}

@end
