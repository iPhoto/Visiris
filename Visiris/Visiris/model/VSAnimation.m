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
#import "VSAnimationCurve.h"

#import "VSCoreServices.h"

@interface VSAnimation()

@property NSUInteger currentKeyframeID;

@end

@implementation VSAnimation


#define kKeyFrames @"KeyFrames"
#define kDeviceParamteMapper @"DeviceParamterMapper"
#define kDefaultValue @"DefaultValue"

@synthesize keyFrames               = _keyFrames;

#pragma mark - Init

-(id) initWithDefaultValue:(id)defaultValue{
    if(self = [super init]){
        _keyFrames =[[NSMutableArray alloc]init];
        self.defaultValue = defaultValue;
    }
    
    return self;
}

-(id) initWithDefaultValue:(id)defaultValue andKeyFrames:(NSMutableArray*) keyFrames{
    if(self = [self initWithDefaultValue:defaultValue]){
        _keyFrames = keyFrames;
    }
    
    return self;
}

#pragma mark - NSCoding Implementation

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.keyFrames forKey:kKeyFrames];
    [aCoder encodeObject:self.deviceParameterMapper forKey:kDeviceParamteMapper];
    [aCoder encodeObject:self.defaultValue forKey:kDefaultValue];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    id defaultValue = [aDecoder decodeObjectForKey:kDefaultValue];
    NSMutableArray *keyFrames = [aDecoder decodeObjectForKey:kKeyFrames];
    
    if(self = [self initWithDefaultValue:defaultValue andKeyFrames:keyFrames]){

    }
    
    return self;
    
}


#pragma mark - NSCopying Implementation

-(id) copyWithZone:(NSZone *)zone{
    VSAnimation *copy = [[VSAnimation allocWithZone:zone] initWithDefaultValue:[self.defaultValue copy] andKeyFrames:[[NSMutableArray alloc] initWithArray:_keyFrames copyItems:YES]];
    
    return copy;
}

#pragma mark - Methods

-(VSKeyFrame*) addKeyFrameWithValue:(id) aValue forTimestamp:(double)aTimestamp{
    
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
            
            float result = [[keyframe1 animationCurve] valueForTime:timestamp
                                                      withBeginTime:keyframe1.timestamp
                                                          toEndTime:keyframe2.timestamp
                                                     withStartValue:keyframe1.floatValue
                                                         toEndValue:keyframe2.floatValue];
            
            
            return result;
            
        }
    }
}

-(NSString*) computeStringValueForTimestamp:(double) timestamp{
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

//todo edi
//- (double)linear:(double)time fromKeyFrame:(VSKeyFrame *)startKeyFrame toKeyFrame:(VSKeyFrame *)endKeyFrame{
//
//    double y, k, deltaY, deltaX, d, x;
//
//    x = time - startKeyFrame.timestamp;
//
//    d = startKeyFrame.floatValue;
//
//    deltaY = endKeyFrame.floatValue - startKeyFrame.floatValue;
//    deltaX = endKeyFrame.timestamp - startKeyFrame.timestamp;
//
//    k = deltaY/deltaX;
//
//    y = k * x + d;
//
//    return  y;
//}
//
//- (double)easeIn:(double)time fromKeyFrame:(VSKeyFrame *)startKeyFrame toKeyFrame:(VSKeyFrame *)endKeyFrame withStrength:(double)strength{
//
//    double d, x, c;
//
//    x = time - startKeyFrame.timestamp;
//
//    d = startKeyFrame.floatValue;
//
//    //c change in value
//    c = endKeyFrame.floatValue - startKeyFrame.floatValue;
//
//    x /= endKeyFrame.timestamp - startKeyFrame.timestamp;
//
//    return c * pow(x,strength) + d;
//}
//
//- (double)easeOut:(double)time fromKeyFrame:(VSKeyFrame *)startKeyFrame toKeyFrame:(VSKeyFrame *)endKeyFrame withStrength:(double)strength{
//
//    double d, x, c;
//
//    x = time - startKeyFrame.timestamp;
//
//    d = startKeyFrame.floatValue;
//
//    //c change in value
//    c = endKeyFrame.floatValue - startKeyFrame.floatValue;
//
//    x /= endKeyFrame.timestamp - startKeyFrame.timestamp;
//
//    x--;
//
//    return -c * (pow(fabs(x),strength) - 1) + d;
//}
//
//- (double)easeInOut:(double)time fromKeyFrame:(VSKeyFrame *)startKeyFrame toKeyFrame:(VSKeyFrame *)endKeyFrame withStrength:(double)strength{
//
//    double d, x, c, result;
//
//    x = time - startKeyFrame.timestamp;
//
//    d = startKeyFrame.floatValue;
//
//    //c change in value
//    c = endKeyFrame.floatValue - startKeyFrame.floatValue;
//
//    x /= (endKeyFrame.timestamp - startKeyFrame.timestamp)/2.0;
//
//
//    if (x < 1.0)
//    {
//        result = (c/2.0) * pow(x, strength) + d;
//    }
//    else
//    {
//        x -= 2;
//        result = -(c/2.0) * (pow(fabs(x), strength) - 2) + d;
//    }
//
//    return result;
//}
@end
