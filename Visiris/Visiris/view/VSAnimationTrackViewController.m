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

-(id) initWithFrame:(NSRect) trackFrame andColor:(NSColor*) trackColor forParameter:(VSParameter*) parameter andPixelTimeRatio:(double) pixelTimeRatio{
    if(self = [super init]){
        self.animationTrackView = [[VSAnimationTrackView alloc]initWithFrame:trackFrame];
        self.view = self.animationTrackView;
        self.animationTrackView.trackColor = trackColor;
        self.parameter = parameter;
        self.pixelTimeRatio = pixelTimeRatio;
        self.keyFrameViewControllers =[[NSMutableArray alloc]init];
        [parameter.animation addObserver:self
               forKeyPath:@"sortedKeyFrameTimestamps"
                  options:0
                  context:nil];
        
        [self initKeyFrames];
    }
    self.parameter.editable = NO;
    return self;
}

-(void) initKeyFrames{
    for(VSKeyFrame *keyframe in [self.parameter.animation.keyFrames allValues]){
        [self addKeyFrameView:keyframe];
    }
}

-(void) addKeyFrameView:(VSKeyFrame*) keyFrame{
    VSKeyFrameViewController *keyFrameViewController = [[VSKeyFrameViewController alloc] initWithKeyFrame:keyFrame withSize:NSMakeSize(KEYFRAME_WIDTH, KEYFRAME_HEIGHT) forPixelTimeRatio:self.pixelTimeRatio];
    
    [self.keyFrameViewControllers addObject:keyFrameViewController];
    
    [self.view addSubview:keyFrameViewController.view];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"sortedKeyFrameTimestamps"]){
        NSArray *newKeyFramesTimestamps = [((NSArray*)[object valueForKey:keyPath]) objectsAtIndexes:[change valueForKey:@"indexes"]];
        
        for(NSNumber *timestamp in newKeyFramesTimestamps){
            [self addKeyFrameView:[self.parameter.animation.keyFrames objectForKey:timestamp]];
        }

    }
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
