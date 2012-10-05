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

/** VSAnimationTrackViewController' view */
@property VSAnimationTrackView *animationTrackView;

/** NSRect where the keyFrames can be positionend and dragged around */
@property (readonly) NSRect keyFramesArea;

/** Holding the paths drawn as connectors between to keyFrames. The ID of the VSKeyFrame the path starts from is used as key */
@property NSMutableDictionary *keyFrameConnectionPaths;

/** VSKeyFrameViewControllers representing the keyFrames the VSAnimationTrackViewController is responsible for */
@property NSMutableArray *keyFrameViewControllers;

@end




@implementation VSAnimationTrackViewController

@synthesize pixelTimeRatio  = _pixelTimeRatio;
@synthesize parameter       = _parameter;

/** Default widht and height of the keyFrameViews */
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
        [self.view setWantsLayer:YES];
        
    }
    return self;
}

/**
 * Iterates through all keyFrames of the parameter's animation and creates a VSKeyFrameViewController for each
 */
-(void) initKeyFrames{
    for(VSKeyFrame *keyframe in self.parameter.animation.keyFrames){
        [self addKeyFrameView:keyframe andSetIsAsSelected:NO];
    }
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    //observes if new keyFrames have been added or have been removed
    if([keyPath isEqualToString:@"keyFrames"]){
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newKeyFrames = [self.parameter.animation.keyFrames objectsAtIndexes:[change valueForKey:@"indexes"]];
                    
                    for(VSKeyFrame *keyFrame in newKeyFrames){
                        [self addKeyFrameView:keyFrame andSetIsAsSelected:YES];
                    }
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if([[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newKeyFrames = [self.parameter.animation.keyFrames objectsAtIndexes:[change valueForKey:@"indexes"]];
                    
                    [self removeKeyFrameViewControllers:newKeyFrames];
                }
                break;
            }
        }
    }
    
    //if the frame of a keyFrameView was changed its neccessary to update the connector-Paths between them
    else if([keyPath isEqualToString:@"view.frame"]){
        if([object isKindOfClass:[VSKeyFrameViewController class]]){
            VSKeyFrameViewController *changedKeyFrame = (VSKeyFrameViewController*)object;
            
            [self frameHasBeenChangedOfKeyFrameViewControllers:changedKeyFrame];
        }
    }
}


-(void) dealloc{
    [self.parameter.animation removeObserver:self
                                  forKeyPath:@"keyFrames"];
    
    [self.parameter.animation removeObserver:self
                                  forKeyPath:@"connectedWithDeviceParameter"];
    
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

-(float) pixelPositonForKeyFramesValue:(VSKeyFrameViewController *)keyFrameViewController{
    
    float pixelPosition = self.view.frame.size.height / 2.0f;
    
    if(self.parameter){
        if(self.parameter.hasRange){
            float range =  self.parameter.range.max - self.parameter.range.min;
            pixelPosition = self.keyFramesArea.size.height / range * (keyFrameViewController.keyFrame.floatValue-self.parameter.range.min);
        }
    }
    pixelPosition -= keyFrameViewController.view.frame.size.width / 2.0f;
    return pixelPosition;
}

-(float) parameterValueOfPixelPosition:(float) pixelPosition forKeyFrame:(VSKeyFrameViewController *) keyFrameViewController{
    if(self.parameter){
        if(self.parameter.hasRange){
            float range =  self.parameter.range.max - self.parameter.range.min;
            return range / self.keyFramesArea.size.height * (pixelPosition) + self.parameter.range.min;
        }
    }
    return keyFrameViewController.keyFrame.floatValue;
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

#pragma mark - Private Methods

/**
 * Called when the frame of one of VSKeyFrameViewController's views have been changed
 * 
 * @param keyFrameViewController VSKeyFrameViewController which's view's frame has been changed
 */
-(void) frameHasBeenChangedOfKeyFrameViewControllers:(VSKeyFrameViewController*) keyFrameViewController{
    
    NSUInteger indexOfObject = [self.keyFrameViewControllers indexOfObject:keyFrameViewController];
    
    BOOL alreadySwapped = NO;
    
    //checks if the new Value of the keyFrame is smaller than the one of the KeyFrame left to it if there is one. If Yes the keyFrame swapp positions and the connection-Path for the prevKeyFrameController is updated
    if(indexOfObject > 0){
        VSKeyFrameViewController *prevKeyFrameController = [self.keyFrameViewControllers objectAtIndex:indexOfObject-1];
        
        if(keyFrameViewController.keyFrame.timestamp < prevKeyFrameController.keyFrame.timestamp){
            [self.keyFrameViewControllers exchangeObjectAtIndex:indexOfObject withObjectAtIndex:indexOfObject-1];
            
            alreadySwapped = YES;
        }
        
        [self addKeyFrameConnectionPathsObject:prevKeyFrameController];
    }
    
    //checks if the new Value of the keyFrame is bigger than the one of the KeyFrame rigth to it if there is one. If Yes the keyFrame swapp positions and the connection-Path for the nextKeyFrameController is updated
    if(!alreadySwapped && indexOfObject + 1 < self.keyFrameViewControllers.count){
        VSKeyFrameViewController *nextKeyFrameController = [self.keyFrameViewControllers objectAtIndex:indexOfObject+1];
        
        if(keyFrameViewController.keyFrame.timestamp > nextKeyFrameController.keyFrame.timestamp){
            [self.keyFrameViewControllers exchangeObjectAtIndex:indexOfObject withObjectAtIndex:indexOfObject+1];
        }
        
        [self addKeyFrameConnectionPathsObject:nextKeyFrameController];
    }
    
    //udpates the keyFrameViewController connection-Path
    [self addKeyFrameConnectionPathsObject:(VSKeyFrameViewController*)keyFrameViewController];
}

/**
 * Creates a new VSKeyFrameViewController for representing the given keyFrame, inits it and adds its view as subview. The selection-state of the newly created VSKeyFrameViewController is set according to the given flag.
 *
 * @param keyFrame VSKeyFrame the VSKeyFrameViewController will be added for
 * @param selected Indicates wheter the selected flag of VSKeyFrameViewController is set to YES or NO
 */
-(void) addKeyFrameView:(VSKeyFrame*) keyFrame andSetIsAsSelected:(BOOL) selected{
    VSKeyFrameViewController *keyFrameViewController = [[VSKeyFrameViewController alloc]
                                                        initWithKeyFrame:keyFrame
                                                        withSize:NSMakeSize(KEYFRAME_WIDTH, KEYFRAME_HEIGHT)
                                                        forPixelTimeRatio:self.pixelTimeRatio                                              andDelegate:self];
    
    if(selected){
        [self unselectAllKeyFrames];
    }
    
    
    
    [self addKeyFrameViewControllersObject:keyFrameViewController];
    
    [self.view addSubview:keyFrameViewController.view];
    
    keyFrameViewController.selected = selected;
    
    [keyFrameViewController addObserver:self
                             forKeyPath:@"view.frame"
                                options:0
                                context:nil];
    
    [self addKeyFrameConnectionPathsObject:keyFrameViewController];
    
    [self.view.layer addSublayer:keyFrameViewController.view.layer];
}

/**
 * Adds the given VSKeyFrameViewController to keyFrameViewControllers and resorts the array according to origin.x of the VSKeyFrameViewControllers views
 *
 * @param object VSKeyFrameViewController which will be added to the keyFrameViewControllers
 */
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
        
        //the connectionPath startsFrom the midPoint of the given object
        [connectionPath moveToPoint:[VSFrameUtils midPointOfFrame:object.view.frame]];
        
        // if there is one KeyFrame right of the newly added the path is lined to its midpoint
        // othwise the path is lined to the end of the trackView 
        if(indexOfObject+1 < self.keyFrameViewControllers.count){
            VSKeyFrameViewController *nextController = [self.keyFrameViewControllers objectAtIndex:indexOfObject+1];
            
            [connectionPath lineToPoint: [VSFrameUtils midPointOfFrame:nextController.view.frame]];
        }
        else{
            [connectionPath lineToPoint:NSMakePoint(NSMaxX(self.view.frame), [VSFrameUtils midPointOfFrame:object.view.frame].y)];
        }
        
        
        
        
        //if there is an keyFrame left of the newly added one the path for stored for the keyFrames ID is linedTo the midPoint of the newly added one
        //Otherwise the line for the path for the key -1 is set up from the left for the track's view to the midpoint of the newly added KeyFrame
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

        //The changed paths are given to the view to be redrawn
        ((VSAnimationTrackView*)self.view).keyFrameConnectionPaths = [self.keyFrameConnectionPaths allValues];
        [self.view setNeedsDisplay:YES];
    }
    else{
        [self clearKeyFrameConnectionPaths];
    }
}

/**
 * Removes all connection-Paths from keyFrameConnectionPaths 
 */
-(void) clearKeyFrameConnectionPaths{
    [self.keyFrameConnectionPaths removeAllObjects];
    
    ((VSAnimationTrackView*)self.view).keyFrameConnectionPaths = [self.keyFrameConnectionPaths allValues];
    [self.view setNeedsDisplay:YES];
}

/**
 * Removes the VSKeyFrameViewControllers stored in the given NSArray by removing their views from their superviews und removing them from keyFrameViewControllers. Besides that the connection-paths are updated
 *
 * @param keyFrameViewControllersToRemove NSArray storing the VSKeyFrameViewControllers which will be removed
 */
-(void) removeKeyFrameViewControllers:(NSArray*) keyFrameViewControllersToRemove{
    
    //finding the indices of the VSKeyFrameViewControllers in the keyFrameViewControllers-Array which shall be removed
    NSIndexSet *keyFramesToRemoveIndices = [self.keyFrameViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSKeyFrameViewController class]]){
            return [keyFrameViewControllersToRemove containsObject:((VSKeyFrameViewController*) obj).keyFrame];
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
    
    [self.parameter.animation addObserver:self
                               forKeyPath:@"connectedWithDeviceParameter"
                                  options:0
                                  context:nil];
}

-(VSParameter*) parameter{
    return _parameter;
}

@end
