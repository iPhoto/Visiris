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
    
    
    
    [self.sortedKeyFrameTimestamps addObject:key];
    
    [self.sortedKeyFrameTimestamps sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([obj1 doubleValue] > [obj2 doubleValue]){
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    DDLogInfo(@"added keyFrame at index: %@", self.sortedKeyFrameTimestamps);
    
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
    
    if(self.keyFrames.count == 0){
        return [self.defaultValue floatValue];
    }
    else if(self.keyFrames.count == 1){
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
        else if(nexKeyFrameIndex == 0){
            return ((VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:0]]).floatValue;
        }
        else{
            VSKeyFrame *keyframe1 = (VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:nexKeyFrameIndex-1]];
            
            VSKeyFrame *keyframe2 = (VSKeyFrame*)[self.keyFrames objectForKey:[self.sortedKeyFrameTimestamps objectAtIndex:nexKeyFrameIndex]];
            float result = ((keyframe2.floatValue - keyframe1.floatValue)  / (keyframe2.timestamp - keyframe1.timestamp) ) * (timestamp-keyframe1.timestamp) + keyframe1.floatValue;
            
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
