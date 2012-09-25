//
//  VSAnimationTimelineTrackViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSAnimationTrackViewController.h"

#import "VSAnimationTrackView.h"
#import "VSParameter.h"
#import "VSAnimation.h"
#import "VSKeyFrame.h"
#import "VSKeyFrameViewController.h"
#import "VSKeyFrameView.h"

#import "VSCoreServices.h"

@interface VSAnimationTrackViewController ()

@property VSAnimationTrackView *animationTrackView;
@property (readonly) NSRect keyFramesArea;
@property NSMutableDictionary *keyFrameConnectionPaths;
@property NSMutableArray *keyFrameViewControllers;

@end

@implementation VSAnimationTrackViewController

@synthesize pixelTimeRatio              = _pixelTimeRatio;
@synthesize parameter                   = _parameter;

#define KEYFRAME_WIDTH  6
#define KEYFRAME_HEIGHT 6

#pragma mark - Init

-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor forParameter:(VSParameter*) parameter andPixelTimeRatio:(double) pixelTimeRatio{
    if(self = [super init]){
        self.animationTrackView = [[VSAnimationTrackView alloc]initWithFrame:trackFrame];
        self.view = self.animationTrackView;
        self.animationTrackView.trackColor = trackColor;
        self.parameter = parameter;
        self.pixelTimeRatio = pixelTimeRatio;
        self.keyFrameViewControllers =[[NSMutableArray alloc]init];
        self.keyFrameConnectionPaths =[[NSMutableDictionary alloc] init];
        [self initKeyFrames];
    }
    self.parameter.editable = NO;
    return self;
}

-(void) initKeyFrames{
    for(VSKeyFrame *keyframe in self.parameter.animation.keyFrames){
        [self addKeyFrameView:keyframe andSetSelectedFlag:NO];
    }
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"keyFrames"]){
        
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newKeyFrames = [self.parameter.animation.keyFrames objectsAtIndexes:[change valueForKey:@"indexes"]];
                    
                    for(VSKeyFrame *keyFrame in newKeyFrames){
                        [self addKeyFrameView:keyFrame andSetSelectedFlag:YES];
                    }
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if([[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newKeyFrames = [self.parameter.animation.keyFrames objectsAtIndexes:[change valueForKey:@"indexes"]];
                    
                    [self removeKeyFrameViews:newKeyFrames];
                }
                break;
            }
        }
    }
    else if([keyPath isEqualToString:@"view.frame"]){
        if([object isKindOfClass:[VSKeyFrameViewController class]]){
            VSKeyFrameViewController *changedKeyFrame = (VSKeyFrameViewController*)object;
            NSUInteger indexOfObject = [self.keyFrameViewControllers indexOfObject:object];
            
            BOOL alreadySwapped = NO;
            
            if(indexOfObject > 0){
                VSKeyFrameViewController *prevKeyFrameController = [self.keyFrameViewControllers objectAtIndex:indexOfObject-1];
                
                if(changedKeyFrame.keyFrame.timestamp < prevKeyFrameController.keyFrame.timestamp){
                    [self.keyFrameViewControllers exchangeObjectAtIndex:indexOfObject withObjectAtIndex:indexOfObject-1];
                    
                    alreadySwapped = YES;
                }
                
                [self addKeyFrameConnectionPathsObject:prevKeyFrameController];
            }
            if(!alreadySwapped && indexOfObject + 1 < self.keyFrameViewControllers.count){
                VSKeyFrameViewController *nextKeyFrameController = [self.keyFrameViewControllers objectAtIndex:indexOfObject+1];
                
                if(changedKeyFrame.keyFrame.timestamp > nextKeyFrameController.keyFrame.timestamp){
                    [self.keyFrameViewControllers exchangeObjectAtIndex:indexOfObject withObjectAtIndex:indexOfObject+1];
                }
                
                [self addKeyFrameConnectionPathsObject:nextKeyFrameController];
            }
            
            [self addKeyFrameConnectionPathsObject:(VSKeyFrameViewController*)object];
        }
    }
}

#pragma mark - Methods

-(VSKeyFrameViewController*) nearestKeyFrameViewRightOfXPosition:(float) xPosition{
    VSKeyFrameViewController *result = nil;
    
    if(self.keyFrameViewControllers.count){
        NSUInteger indexOfNearest = [self.keyFrameViewControllers indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            VSKeyFrameViewController *keyFrameViewController = (VSKeyFrameViewController*)obj;
            if(keyFrameViewController.view.frame.origin.x > xPosition){
                
                NSPoint position = NSMakePoint(xPosition, keyFrameViewController.view.frame.origin.y);
                
                if(!NSPointInRect(position, keyFrameViewController.view.frame)){
                    return YES;
                }
            }
            
            return NO;
        }];
        
        if(indexOfNearest != NSNotFound)
            result = [self.keyFrameViewControllers objectAtIndex:indexOfNearest];
    }
    
    return result;
}

-(VSKeyFrameViewController*) nearestKeyFrameViewLeftOfXPosition:(float) xPosition{
    
    VSKeyFrameViewController *result = nil;
    
    
    if(self.keyFrameViewControllers.count){
        NSUInteger indexOfNearest = [self.keyFrameViewControllers indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[VSKeyFrameViewController class]]){
                VSKeyFrameViewController *keyFrameViewController = (VSKeyFrameViewController*)obj;
                if(keyFrameViewController.view.frame.origin.x < xPosition){
                    
                    NSPoint position = NSMakePoint(xPosition, keyFrameViewController.view.frame.origin.y);
                    
                    if(!NSPointInRect(position, keyFrameViewController.view.frame)){
                        return YES;
                    }
                }
            }
            
            return NO;
        }];
        
        if(indexOfNearest != NSNotFound)
            result = [self.keyFrameViewControllers objectAtIndex:indexOfNearest];
    }
    
    return result;
}

-(VSKeyFrameViewController*) keyFrameViewControllerAtXPosition:(float) xPosition{
    for(VSKeyFrameViewController *keyFrameViewController in self.keyFrameViewControllers){
        NSPoint testPoint = NSMakePoint(xPosition, keyFrameViewController.keyFrameView.frame.origin.y);
        
        if(NSPointInRect(testPoint, keyFrameViewController.keyFrameView.frame)){
            return keyFrameViewController;
        }
    }
    
    return nil;
}

-(void) unselectAllKeyFrames{
    for(VSKeyFrameViewController *keyFrameViewController in self.keyFrameViewControllers){
        keyFrameViewController.selected = false;
    }
}

-(void) removeSelectedKeyFrames{
    for(NSInteger i = self.keyFrameViewControllers.count-1;i >= 0; i--){
        VSKeyFrameViewController *keyFrameViewController = [self.keyFrameViewControllers objectAtIndex:i];
        if(keyFrameViewController.selected){
            [self.parameter removeKeyFrame:keyFrameViewController.keyFrame];
        }
    }
}

#pragma mark - VSKeyFrameViewControllerDelegate Implementation

-(BOOL) keyFrameViewControllerWantsToBeSelected:(VSKeyFrameViewController *)keyFrameViewController{
    BOOL result = false;
    
    if([self delegateRespondsToSelector:@selector(keyFrameViewController:wantsToBeSelectedOnTrack:)]){
        result = [self.delegate keyFrameViewController:keyFrameViewController
                              wantsToBeSelectedOnTrack:self];
    }
    
    return result;
}

-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController *)keyFrameViewController wantsToBeDraggeFrom:(NSPoint)fromPoint to:(NSPoint)toPoint{
    if((toPoint.x - keyFrameViewController.view.frame.size.width / 2.0f) < 0){
        toPoint.x = 0;
    }
    else if((toPoint.x + keyFrameViewController.view.frame.size.width / 2.0f) > self.keyFramesArea.size.width){
        toPoint.x = self.keyFramesArea.size.width - keyFrameViewController.view.frame.size.width;
    }
    
    if((toPoint.y - keyFrameViewController.view.frame.size.height / 2.0f) < 0){
        toPoint.y = keyFrameViewController.view.frame.size.height / 2.0f;
    }
    else if((toPoint.y + keyFrameViewController.view.frame.size.height / 2.0f) > self.keyFramesArea.size.height){
        toPoint.y = self.keyFramesArea.size.height - keyFrameViewController.view.frame.size.height / 2.0f;
    }
    
    NSPoint result = toPoint;
    
    if([self delegateRespondsToSelector:@selector(keyFrameViewControllersView:wantsToBeDraggedFrom:to:onTrack:)]){
        result = [self.delegate keyFrameViewControllersView:keyFrameViewController
                                       wantsToBeDraggedFrom:fromPoint
                                                         to:toPoint
                                                    onTrack:self];
    }
    
    return result;
}

-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *)keyFrameViewController{
    
    float pixelPosition = self.view.frame.size.height / 2.0f;
    
    if(self.parameter){
        if(self.parameter.hasRange){
            float range =  self.parameter.rangeMaxValue - self.parameter.rangeMinValue;
            pixelPosition = self.keyFramesArea.size.height / range * (keyFrameViewController.keyFrame.floatValue-self.parameter.rangeMinValue);
        }
    }
    pixelPosition -= keyFrameViewController.view.frame.size.width / 2.0f;
    return pixelPosition;
}

-(float) parameterValueOfPixelPosition:(float) pixelValue forKeyFrame:(VSKeyFrameViewController *) keyFrameViewController{
    if(self.parameter){
        if(self.parameter.hasRange){
            float range =  self.parameter.rangeMaxValue - self.parameter.rangeMinValue;
            return range / self.keyFramesArea.size.height * (pixelValue) + self.parameter.rangeMinValue;
        }
    }
    return keyFrameViewController.keyFrame.floatValue;
}

#pragma mark - Private Methods

-(void) addKeyFrameView:(VSKeyFrame*) keyFrame andSetSelectedFlag:(BOOL) selected{
    VSKeyFrameViewController *keyFrameViewController = [[VSKeyFrameViewController alloc] initWithKeyFrame:keyFrame
                                                                                                 withSize:NSMakeSize(KEYFRAME_WIDTH, KEYFRAME_HEIGHT)
                                                                                        forPixelTimeRatio:self.pixelTimeRatio
                                                                                              andDelegate:self];
    
    if(selected){
        [self unselectAllKeyFrames];
    }
    
    
    
    [self addKeyFrameViewControllersObject:keyFrameViewController];
    
    [self.view addSubview:keyFrameViewController.view];
    
    [keyFrameViewController addObserver:self forKeyPath:@"view.frame" options:0 context:nil];
    
    [self addKeyFrameConnectionPathsObject:keyFrameViewController];
    
    keyFrameViewController.selected = selected;
}

-(void) addKeyFrameViewControllersObject:(VSKeyFrameViewController *)object{
    [self.keyFrameViewControllers addObject:object];
    
    [self.keyFrameViewControllers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if(((VSKeyFrameViewController*) obj1).view.frame.origin.x < ((VSKeyFrameViewController*) obj2).view.frame.origin.x){
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
}

-(void) addKeyFrameConnectionPathsObject:(VSKeyFrameViewController *)object{
    
    if(self.keyFrameViewControllers.count){
        NSUInteger indexOfObject = [self.keyFrameViewControllers indexOfObject:object];
        
        NSBezierPath *connectionPath = [[NSBezierPath alloc]init];
        
        [connectionPath moveToPoint:[VSFrameUtils midPointOfFrame:object.view.frame]];
        
        if(indexOfObject+1 < self.keyFrameViewControllers.count){
            VSKeyFrameViewController *nextController = [self.keyFrameViewControllers objectAtIndex:indexOfObject+1];
            
            [connectionPath lineToPoint: [VSFrameUtils midPointOfFrame:nextController.view.frame]];
        }
        else{
            [connectionPath lineToPoint:NSMakePoint(NSMaxX(self.view.frame), [VSFrameUtils midPointOfFrame:object.view.frame].y)];
        }
        
        if(indexOfObject> 0){
            NSBezierPath *pathToNewKeyFrame = [[NSBezierPath alloc] init];
            
            VSKeyFrameViewController *prevController = [self.keyFrameViewControllers objectAtIndex:indexOfObject-1];
            
            [pathToNewKeyFrame moveToPoint:[VSFrameUtils midPointOfFrame:prevController.view.frame]];
            [pathToNewKeyFrame lineToPoint:[VSFrameUtils midPointOfFrame:object.view.frame]];
            
            [self.keyFrameConnectionPaths setObject:pathToNewKeyFrame forKey:[NSNumber numberWithInteger:prevController.keyFrame.ID]];
        }
        else
        {
            NSBezierPath *pathToNewKeyFrame = [[NSBezierPath alloc] init];
            
            [pathToNewKeyFrame moveToPoint:NSMakePoint(self.view.frame.origin.x, [VSFrameUtils midPointOfFrame:object.view.frame].y)];
            [pathToNewKeyFrame lineToPoint:[VSFrameUtils midPointOfFrame:object.view.frame]];
            
            [self.keyFrameConnectionPaths setObject:pathToNewKeyFrame forKey:[NSNumber numberWithInteger:-1]];
        }
        
        [self.keyFrameConnectionPaths setObject:connectionPath forKey:[NSNumber numberWithInteger:object.keyFrame.ID]];
        
        ((VSAnimationTrackView*)self.view).keyFrameConnectionPaths = [self.keyFrameConnectionPaths allValues];
        [self.view setNeedsDisplay:YES];
    }
    else{
        [self clearKeyFrameConnectionPaths];
    }
    
    
}

-(void) clearKeyFrameConnectionPaths{
    [self.keyFrameConnectionPaths removeAllObjects];
    
    ((VSAnimationTrackView*)self.view).keyFrameConnectionPaths = [self.keyFrameConnectionPaths allValues];
    [self.view setNeedsDisplay:YES];
}

-(void) removeKeyFrameViews:(NSArray*) keyFramesToRemove{
    
    //finding the indices of the VSKeyFrameViewControllers in the keyFrameViewControllers-Array which shall be removed
    NSIndexSet *keyFramesToRemoveIndices = [self.keyFrameViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSKeyFrameViewController class]]){
            return [keyFramesToRemove containsObject:((VSKeyFrameViewController*) obj).keyFrame];
        }
        return NO;
    }];
    
    
    //iterates through the VSKeyFrameViewControllers to be removed. Removes them from its superView and removes their connections
    for(VSKeyFrameViewController *keyFrameViewController in [self.keyFrameViewControllers objectsAtIndexes:keyFramesToRemoveIndices]){
        [keyFrameViewController.view removeFromSuperview];
        [keyFrameViewController removeObserver:self forKeyPath:@"view.frame"];
        [self.keyFrameConnectionPaths removeObjectForKey:[NSNumber numberWithInteger:keyFrameViewController.keyFrame.ID]];
    }
    
    [self.keyFrameViewControllers removeObjectsAtIndexes:keyFramesToRemoveIndices];
    
    if(self.keyFrameViewControllers.count){
        NSUInteger currIndex = [keyFramesToRemoveIndices firstIndex];
        
        while (currIndex != NSNotFound) {
            if(currIndex > 0){
                [self addKeyFrameConnectionPathsObject:[self.keyFrameViewControllers objectAtIndex:currIndex-1]];
            }
            else if(currIndex == 0){
                [self addKeyFrameConnectionPathsObject:[self.keyFrameViewControllers objectAtIndex:0]];
            }
            currIndex = [keyFramesToRemoveIndices indexGreaterThanIndex:currIndex];
        }
    }
    else{
        [self clearKeyFrameConnectionPaths];
    }
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSAnimationTrackViewControllerDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}



#pragma mark - Properties

-(NSRect) keyFramesArea{
    return self.view.frame;
}

-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    _pixelTimeRatio = pixelTimeRatio;
    for(VSKeyFrameViewController *keyFrameViewController in self.keyFrameViewControllers){
        keyFrameViewController.pixelTimeRatio = self.pixelTimeRatio;
    }
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

-(void) setParameter:(VSParameter *)parameter{
    _parameter = parameter;
    
    [self.parameter.animation addObserver:self
                               forKeyPath:@"keyFrames"
                                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
                                  context:nil];
}

-(VSParameter*) parameter{
    return _parameter;
}

-(void) dealloc{
    [self.parameter.animation removeObserver:self
                                  forKeyPath:@"keyFrames"];
}

@end
