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

@interface VSKeyFrameViewController ()

@property NSSize size;

@end 


@implementation VSKeyFrameViewController

@synthesize pixelTimeRatio  = _pixelTimeRatio;

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
        
    }
    
    return self;
}

-(void) initObservers{
    [self.keyFrame addObserver:self forKeyPath:@"value" options:0 context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"value"]){
        [self.view setFrame:[self computeFrameRect]];
    }
}

-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

-(double) pixelForTimestamp:(double) timestamp{
    return timestamp / self.pixelTimeRatio;
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

#pragma mark - Private Methods

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

-(NSRect) computeFrameRect{
    float originX = [self pixelForTimestamp:self.keyFrame.timestamp] - self.view.frame.size.width / 2.0f;
    float originY = self.view.frame.size.height / 2.0f;
    
    if([self delegateRespondsToSelector:@selector(pixelPositonForKeyFramesValue:)]){
        originY = [self.delegate pixelPositonForKeyFramesValue:self];

    }
    
    return NSMakeRect(originX, originY, self.size.width, self.size.height);
}

#pragma mark - Properties


-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    _pixelTimeRatio = pixelTimeRatio;
    
    [self.keyFrameView setFrame: [self computeFrameRect]];
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

-(BOOL) getSelected{
    return self.keyFrameView.selected;
}

-(void) setSelected:(BOOL)selected{
    self.keyFrameView.selected = selected;
}

@end
