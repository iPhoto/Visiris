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

@end

@implementation VSAnimationTrackViewController

@synthesize pixelTimeRatio = _pixelTimeRatio;

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
        [parameter.animation addObserver:self
                              forKeyPath:@"keyFrames"
                                 options:0
                                 context:nil];
        
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
        result = [self.delegate keyFrameViewController:keyFrameViewController wantsToBeSelectedOnTrack:self];
    }
    
    return result;
}

-(NSPoint) keyFrameViewControllersView:(VSKeyFrameViewController *)keyFrameViewController wantsToBeDraggeFrom:(NSPoint)fromPoint to:(NSPoint)toPoint{
    
    NSPoint result = toPoint;
    
    if([self delegateRespondsToSelector:@selector(keyFrameViewControllersView:wantsToBeDraggeFrom:to:onTrack:)]){
        result = [self.delegate keyFrameViewControllersView:keyFrameViewController wantsToBeDraggeFrom:fromPoint to:toPoint onTrack:self];
    }
    
    DDLogInfo(@"keyFrameViewControllers %@", self.keyFrameViewControllers);
    DDLogInfo(@"keyFrames %@",self.parameter.animation.keyFrames);
    
    return result;
}

#pragma mark - Private Methods

-(void) addKeyFrameView:(VSKeyFrame*) keyFrame{
    VSKeyFrameViewController *keyFrameViewController = [[VSKeyFrameViewController alloc] initWithKeyFrame:keyFrame withSize:NSMakeSize(KEYFRAME_WIDTH, KEYFRAME_HEIGHT) forPixelTimeRatio:self.pixelTimeRatio];
    
    keyFrameViewController.delegate = self;
    [self.keyFrameViewControllers addObject:keyFrameViewController];
    
    [self.view addSubview:keyFrameViewController.view];
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

-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    _pixelTimeRatio = pixelTimeRatio;
    for(VSKeyFrameViewController *keyFrameViewController in self.keyFrameViewControllers){
        keyFrameViewController.pixelTimeRatio = self.pixelTimeRatio;
    }
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

@end
