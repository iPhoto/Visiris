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
@property NSMutableArray *keyFrameConnectionPaths;

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
        self.keyFrameConnectionPaths =[[NSMutableArray alloc] init];
        [self initKeyFrames];
    }
    self.parameter.editable = NO;
    return self;
}

-(void) initKeyFrames{
    for(VSKeyFrame *keyframe in self.parameter.animation.keyFrames){
        [self addKeyFrameView:keyframe];
    }
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"keyFrames"]){
        if([[change valueForKey:@"kind"] intValue] == NSKeyValueMinusSetMutation){
            NSArray *newKeyFrames = [self.parameter.animation.keyFrames objectsAtIndexes:[change valueForKey:@"indexes"]];
            
            for(VSKeyFrame *keyFrame in newKeyFrames){
                [self addKeyFrameView:keyFrame];
            }
        }
    }
    else if([keyPath isEqualToString:@"frame"]){
        
    }
}

#pragma mark - Methods

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
    
    if((toPoint.x - keyFrameViewController.view.frame.size.width / 2.0f) < self.keyFramesArea.origin.x){
        toPoint.x = self.keyFramesArea.origin.x + keyFrameViewController.view.frame.size.width / 2.0f;
    }
    else if((toPoint.x + keyFrameViewController.view.frame.size.width / 2.0f) > self.keyFramesArea.size.width){
        toPoint.x = self.keyFramesArea.size.width - keyFrameViewController.view.frame.size.width / 2.0f;
    }
    
    if((toPoint.y + keyFrameViewController.view.frame.size.height / 2.0f) < self.keyFramesArea.origin.y){
        
        toPoint.y = self.keyFramesArea.origin.y - keyFrameViewController.view.frame.size.height / 2.0f;
    }
    else if((toPoint.y - keyFrameViewController.view.frame.size.height / 2.0f) > self.keyFramesArea.size.height){
        toPoint.y = self.keyFramesArea.origin.y + self.keyFramesArea.size.height + keyFrameViewController.view.frame.size.height / 2.0f;
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

-(void) addKeyFrameView:(VSKeyFrame*) keyFrame{
    VSKeyFrameViewController *keyFrameViewController = [[VSKeyFrameViewController alloc] initWithKeyFrame:keyFrame
                                                                                                 withSize:NSMakeSize(KEYFRAME_WIDTH, KEYFRAME_HEIGHT)
                                                                                        forPixelTimeRatio:self.pixelTimeRatio
                                                                                              andDelegate:self];
    
    [self.keyFrameViewControllers addObject:keyFrameViewController];
    
    [self.view addSubview:keyFrameViewController.view];
    
    [self.keyFrameViewControllers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if(((VSKeyFrameViewController*) obj1).view.frame.origin.x < ((VSKeyFrameViewController*) obj1).view.frame.origin.x){
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    [keyFrameViewController.view addObserver:self forKeyPath:@"frame" options:0 context:nil];
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
    return NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y+10, self.view.frame.size.width, self.view.frame.size.height-20);
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
                                  options:0
                                  context:nil];
}

-(VSParameter*) parameter{
    return _parameter;
}

-(void) dealloc{
    [self.parameter.animation removeObserver:self forKeyPath:@"keyFrames"];
}

@end
