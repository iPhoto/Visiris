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

@property NSUInteger currentKeyframeID;

@end

@implementation VSAnimation

/** Timestamp of the default KeyFrame */

@synthesize deviceParameterMapper   = _deviceParameterMapper;
@synthesize keyFrames               = _keyFrames;

#pragma mark - Init

-(id) init{
    if(self = [super init]){
        _keyFrames =[[NSMutableArray alloc]init];
    }
    
    return self;
}

-(id) initWithKeyFrames:(NSMutableArray*) keyFrames{
    if(self = [self init]){
        _keyFrames = keyFrames;
    }
    
    return self;
}


#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSAnimation *copy = [[VSAnimation allocWithZone:zone] initWithKeyFrames:[[NSMutableArray alloc] initWithArray:_keyFrames copyItems:YES]];

    return copy;
}

#pragma mark - Methods

-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    
    DDLogInfo(@"addKeyFrameWithValue");
    
    if(!self.keyFrames){
        _keyFrames = [[NSMutableArray alloc]init];
    }
    
    VSKeyFrame* newKeyFrame = [[VSKeyFrame alloc] initWithValue:aValue forTimestamp:aTimestamp andID:[self nextKeyFrameID]];
    
    [self.keyFrames addObject:newKeyFrame];

    [self.keyFrames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([obj1 timestamp] > [obj2 timestamp]){
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    

    
    return newKeyFrame;
}

-(void) removeKeyFrame:(VSKeyFrame *)keyFrame{
    [self.keyFrames removeObject:keyFrame];
}

-(void) changeKeyFrames:(VSKeyFrame *)keyFrame timestamp:(double)newTimestamp{
    keyFrame.timestamp = newTimestamp;
    
    [self.keyFrames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([obj1 timestamp] > [obj2 timestamp]){
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

#pragma mark Computing current Values

-(float) computeFloatValueForTimestamp:(double)timestamp{
    
    if(self.keyFrames.count == 0){
        return [self.defaultValue floatValue];
    }
    else if(self.keyFrames.count == 1){
        return ((VSKeyFrame*)[self.keyFrames objectAtIndex:0]).floatValue;
    }
    else{
        NSUInteger nexKeyFrameIndex = [self.keyFrames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj timestamp] > timestamp){
                return YES;
            }
            return NO;
        }];
        
        if(nexKeyFrameIndex == NSNotFound){
            
            return ((VSKeyFrame*)[self.keyFrames lastObject]).floatValue;
        }
        else if(nexKeyFrameIndex == 0){
            return ((VSKeyFrame*)[self.keyFrames objectAtIndex:0]).floatValue;
        }
        else{
            VSKeyFrame *keyframe1 = (VSKeyFrame*)[self.keyFrames objectAtIndex:nexKeyFrameIndex-1];
            
            VSKeyFrame *keyframe2 = (VSKeyFrame*)[self.keyFrames objectAtIndex:nexKeyFrameIndex];
            float result = ((keyframe2.floatValue - keyframe1.floatValue)  / (keyframe2.timestamp - keyframe1.timestamp) ) * (timestamp-keyframe1.timestamp) + keyframe1.floatValue;
            
            return result;
            
        }
    }
}

-(NSString*) computStringValueForTimestamp:(double) timestamp{
    if(self.keyFrames.count == 0){
        return self.defaultValue;
    }
    else if(self.keyFrames.count == 1){
        return ((VSKeyFrame*)[self.keyFrames  objectAtIndex:0]).stringValue;
    }
    else{
        NSUInteger nexKeyFrameIndex = [self.keyFrames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj timestamp] > timestamp){
                return YES;
            }
            return NO;
        }];
        
        
        if(nexKeyFrameIndex == NSNotFound){
            
            return ((VSKeyFrame*)[self.keyFrames lastObject]).stringValue;
        }
        else if(nexKeyFrameIndex == 0){
            return ((VSKeyFrame*)[self.keyFrames objectAtIndex:0]).stringValue;
        }
        else{
            return ((VSKeyFrame*)[self.keyFrames objectAtIndex:nexKeyFrameIndex-1]).stringValue;
        }
    }
}

-(BOOL) copmuteBoolValueForTimestamp:(double) timestamp{
    if(self.keyFrames.count == 0){
        return [self.defaultValue boolValue];
    }
    else if(self.keyFrames.count == 1){
        return ((VSKeyFrame*)[self.keyFrames objectAtIndex:0]).boolValue;
    }
    else{
        NSUInteger nexKeyFrameIndex = [self.keyFrames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj timestamp] > timestamp){
                return YES;
            }
            return NO;
        }];
        
        if(nexKeyFrameIndex == NSNotFound){
            
            return ((VSKeyFrame*)[self.keyFrames lastObject]).boolValue;
        }
        else if(nexKeyFrameIndex == 0){
            return ((VSKeyFrame*)[self.keyFrames objectAtIndex:0]).boolValue;
        }
        else{
            return ((VSKeyFrame*)[self.keyFrames objectAtIndex:nexKeyFrameIndex-1]).boolValue;
        }
    }
}

#pragma mark - Private Methods

/**
 * Generates the next available, unique ID for a keyFrame
 * @return Unique ID for an keyFrame of the animation
 */
-(NSUInteger) nextKeyFrameID{
    return ++self.currentKeyframeID;
}

#pragma mark - Properties

-(NSMutableArray*) keyFrames
{
    NSMutableArray *result= [self mutableArrayValueForKey:@"keyFrames"];
    return result;
}

-(void) insertObject:(VSKeyFrame *)object inKeyFramesAtIndex:(NSUInteger)index{
    [self.keyFrames insertObject:object atIndex:index];
}

-(void) insertKeyFrames:(NSArray *)array atIndexes:(NSIndexSet *)indexes{
    [self.keyFrames insertObjects:array atIndexes:indexes];
}

@end
