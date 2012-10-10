//
//  VSKeyFrameViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import "VSKeyFrameViewController.h"

#import "VSKeyFrameView.h"
#import "VSKeyFrame.h"
#import "VSAnimationCurve.h"

@interface VSKeyFrameViewController ()

/** Size of the VSKeyFrameView the VSKeyFrameViewController is responsible for */
@property NSSize size;

@end




@implementation VSKeyFrameViewController

@synthesize pixelTimeRatio              = _pixelTimeRatio;
@synthesize nextKeyFrameViewController  = _nextKeyFrameViewController;

#pragma mark - Init

- (id)initWithKeyFrame:(VSKeyFrame *)keyFrame withSize:(NSSize)size forPixelTimeRatio:(double)pixelTimeRatio andDelegate:(id<VSKeyFrameViewControllerDelegate>)delegate{
    if(self = [super init]){
        self.keyFrame = keyFrame;
        self.size = size;
        self.view = self.keyFrameView = [[VSKeyFrameView alloc] init];
        self.pixelTimeRatio = pixelTimeRatio;
        self.delegate = delegate;
        
        [self initObservers];
        
        [self.view setFrame:[self computeFrameRect]];
        self.keyFrameView.mouseDelegate = self;
        self.keyFrameView.resizingDelegate = self;
        
    }
    
    return self;
}

-(void) initObservers{
    [self.keyFrame addObserver:self forKeyPath:@"value" options:0 context:nil];
    
    [self.keyFrame addObserver:self
                    forKeyPath:@"animationCurve"
                       options:0
                       context:nil];
    [self.keyFrame addObserver:self
                    forKeyPath:@"animationCurve.strength"
                       options:0
                       context:nil];
}

#pragma mark - NSViewController

-(void) dealloc{
    [self.keyFrame removeObserver:self
                       forKeyPath:@"value"];
    
    [self.keyFrame removeObserver:self
                       forKeyPath:@"animationCurve"];
    
    [self.keyFrame removeObserver:self
                       forKeyPath:@"animationCurve.strength"];
    
    if(self.nextKeyFrameViewController){
        [self.nextKeyFrameViewController removeObserver:self
                                             forKeyPath:@"view.frame"];
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"value"]){
        [self.view setFrame:[self computeFrameRect]];
    }
    else if([keyPath isEqualToString:@"animationCurve"]){
        [self updateConnectionPathToNextKeyFrame];
    }
    else if([keyPath isEqualToString:@"animationCurve.strength"]){
        [self updateConnectionPathToNextKeyFrame];
    }
    else if([keyPath isEqualToString:@"view.frame"]){
        [self updateConnectionPathToNextKeyFrame];
    }
}

#pragma mark - VSViewMouseEventsDelegate

-(void) mouseDown:(NSEvent *)theEvent onView:(NSView *)view{
    
    
    if([self delegateRespondsToSelector:@selector(keyFrameViewControllerWantsToBeSelected:)]){
        self.selected = [self.delegate keyFrameViewControllerWantsToBeSelected:self];
    }
}

-(NSPoint) view:(NSView *)view wantsToBeDraggedFrom:(NSPoint)fromPoint to:(NSPoint)toPoint{
    NSPoint result = toPoint;
    if(view ==self.keyFrameView){
        if([self delegateRespondsToSelector:@selector(keyFrameViewControllersView:wantsToBeDraggeFrom:to:)]){
            result = [self.delegate keyFrameViewControllersView:self wantsToBeDraggeFrom:fromPoint to:toPoint];
        }
    }
    
    return result;
}

#pragma mark - VSViewResizingDelegate Implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    [self updateConnectionPathToNextKeyFrame];
}

#pragma mark - Private Methods

-(void) updateConnectionPathToNextKeyFrame{
    
    if(self.nextKeyFrameViewController){
        
        
        self.pathToNextKeyFrameView = [[NSBezierPath alloc] init];
        
        [self.pathToNextKeyFrameView moveToPoint:[VSFrameUtils midPointOfFrame:self.view.frame]];
        
        
        float startXPosition = [VSFrameUtils midPointOfFrame:self.view.frame].x;
        float endXPosition = [VSFrameUtils midPointOfFrame:self.nextKeyFrameViewController.view.frame].x;
        float startYPosition = [VSFrameUtils midPointOfFrame:self.view.frame].y;
        float endYPosition = [VSFrameUtils midPointOfFrame:self.nextKeyFrameViewController.view.frame].y;
        
        float xDistance = endXPosition - startXPosition;
        int pixelDelta = 1;
        int end = floor(xDistance / pixelDelta);
        
        
        for(int i = 1; i < end; i++){
            
            float xPosition = startXPosition + i*pixelDelta;
            
            double yPosition = [self.keyFrame.animationCurve valueForTime:xPosition
                                                            withBeginTime:startXPosition
                                                                toEndTime:endXPosition
                                                           withStartValue:startYPosition
                                                               toEndValue:endYPosition];
            
            [self.pathToNextKeyFrameView lineToPoint: NSMakePoint(xPosition, yPosition)];
        }
        
        [self.pathToNextKeyFrameView lineToPoint: [VSFrameUtils midPointOfFrame:self.nextKeyFrameViewController.view.frame]];
    }
    else{
        self.pathToNextKeyFrameView = nil;
    }
    
    if([self delegateRespondsToSelector:@selector(keyFrameViewController:updatedPathToNextKeyFrame:)]){
        [self.delegate keyFrameViewController:self updatedPathToNextKeyFrame:self.pathToNextKeyFrameView];
    }
}


/**
 * Converts the given pixelPosition to a timestamp according to the current pixelTimeRatio
 * @param pixelPosition x-Position to be converted to a timestamp
 * @return Corresponding timestamp to the given pixelPosition
 */
-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

/**
 * Converts the given timestamp to a pixel-position according to the current pixelTimeRatio
 * @param timestamp to be converted to a pixel-position
 * @return Corresponding position to the given timestamp
 */
-(double) pixelForTimestamp:(double) timestamp{
    return timestamp / self.pixelTimeRatio;
}

/**
 * Computes the frame-rect for the VSKeyFrameViewController's view according to its timestamp and value
 * @return NSRect defining size and position of the VSKeyFrameViewController's view
 */
-(NSRect) computeFrameRect{
    float originX = [self pixelForTimestamp:self.keyFrame.timestamp] - self.view.frame.size.width / 2.0f;
    float originY = self.view.frame.size.height / 2.0f;
    
    if([self delegateRespondsToSelector:@selector(pixelPositonForKeyFramesValue:)]){
        originY = [self.delegate pixelPositonForKeyFramesValue:self];
        
    }
    
    return NSMakeRect(originX, originY, self.size.width, self.size.height);
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSKeyFrameViewControllerDelegate)]){
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
    
    [self.keyFrameView setFrame: [self computeFrameRect]];
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

-(BOOL) selected{
    return self.keyFrameView.selected;
}

-(void) setSelected:(BOOL)selected{
    self.keyFrameView.selected = selected;
}

-(void) setNextKeyFrameViewController:(VSKeyFrameViewController *)nextKeyFrameViewController{
    
    if(_nextKeyFrameViewController){
        [_nextKeyFrameViewController removeObserver:self
                                         forKeyPath:@"view.frame"];
        
    }
    _nextKeyFrameViewController = nextKeyFrameViewController;
    
    if(_nextKeyFrameViewController){
        [_nextKeyFrameViewController addObserver:self
                                      forKeyPath:@"view.frame"
                                         options:0
                                         context:nil];
        
        
    }
    
    [self updateConnectionPathToNextKeyFrame];
}

-(VSKeyFrameViewController*) nextKeyFrameViewController{
    return _nextKeyFrameViewController;
}


@end
