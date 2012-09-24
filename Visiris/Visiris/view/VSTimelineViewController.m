//
//  VSTimelineViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.08.12.
//
//

#import "VSTimelineViewController.h"

#import "VSTimelineScrollView.h"

#import "VSCoreServices.h"

@interface VSTimelineViewController ()




@end

@implementation VSTimelineViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    
    [self initScrollView];
    
    if([self.view isKindOfClass:[VSTimelineView class]]){
        ((VSTimelineView*) self.view).resizingDelegate = self;
        ((VSTimelineView*) self.view).mouseMoveDelegate = self;
        ((VSTimelineView*) self.view).keyDownDelegate = self;
    }
}

/**
 * Sets the frame of the trackHolder and the AutoresizingMasks
 */
-(void) initScrollView{
    self.timelineScrollView.zoomingDelegate = self;
    self.timelineScrollView.playheadMarkerDelegate = self;
}

#pragma mark- VSViewResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    
    if(newRect.size.width != 0){
        
        if(oldRect.size.width != newRect.size.width){
            
            NSRect newDocumentFrame = [self.timelineScrollView.trackHolderView frame];
            
            //updates the width according to how the width of the view has been resized
            newDocumentFrame.size.width += newRect.size.width - oldRect.size.width;
            [self.timelineScrollView.trackHolderView setFrame:(newDocumentFrame)];
            [self computePixelTimeRatio];
        }
    }
}



#pragma mark - VSViewKeyDownDelegate

-(void) didReceiveKeyDownEvent:(NSEvent *)theEvent{
    if(theEvent){
        unichar keyCode = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
        switch (keyCode) {
            case 32:
                [[NSNotificationCenter defaultCenter] postNotificationName:VSPlayKeyWasPressed object:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark - VSTimelineScrollViewZoomingDelegate

-(void) timelineScrollView:(VSTimelineScrollView *)scrollView wasZoomedAtPosition:(NSPoint)position{
    double positionTimestamp =[self timestampForPixelValue:position.x];
    
    [self computePixelTimeRatio];
    
    float newPosition = [self pixelForTimestamp:positionTimestamp];
    
    float ratio = position.x - newPosition;
    NSRect clipViewBounds = self.timelineScrollView.contentView.bounds;
    clipViewBounds.origin.x -= ratio;
    
    [self.timelineScrollView.contentView setBounds:clipViewBounds];
}

-(NSRect) timelineScrollView:(VSTimelineScrollView *)scrollView wantsToBeZoomedAccordingToScrollWheel:(float)amount atPosition:(NSPoint)mousePosition forCurrentFrame:(NSRect)currentFrame{
    if(amount == 0.0)// || self.trackHolder.frame.size.width < self.scrollView.documentVisibleRect.size.width)
        return currentFrame;
    
    NSRect newTrackHolderFrame = currentFrame;
    
    float zoomFactor = 1.0 + amount;
    
    float deltaWidth = self.timelineScrollView.documentVisibleRect.size.width * zoomFactor -self.timelineScrollView.documentVisibleRect.size.width;
    
    newTrackHolderFrame.size.width += deltaWidth;
    
    if(newTrackHolderFrame.size.width < self.timelineScrollView.documentVisibleRect.size.width){
        newTrackHolderFrame.size.width = self.timelineScrollView.documentVisibleRect.size.width;
    }
    
    return newTrackHolderFrame;
}


#pragma mark - Methods

-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

-(double) pixelForTimestamp:(double) timestamp{
    if(self.pixelTimeRatio > 0)
        return timestamp / self.pixelTimeRatio;
    else
        return 0;
}

-(void) computePixelTimeRatio{
    
    if(self.pixelLength > 0){
        double newRatio = self.duration / self.pixelLength;
        
        if(newRatio < VSMinimumPixelTimeRatio)
        {
            newRatio = VSMinimumPixelTimeRatio;
        }
        
        if(newRatio != self.pixelTimeRatio){
            self.pixelTimeRatio = newRatio;
            [self pixelTimeRatioDidChange];
        }
    }
}

/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange{
    self.timelineScrollView.trackHolderWidth = [self pixelForTimestamp:self.duration];
    [self setPlayheadMarkerLocation];
    self.timelineScrollView.pixelTimeRatio = self.pixelTimeRatio;
}

/**
 * Sets the plahead marker according to the playhead's currentposition on the timeline
 */
-(void) setPlayheadMarkerLocation{
    CGFloat newLocation = [self pixelForTimestamp:self.playheadTimePosition];
    
    [self.timelineScrollView movePlayHeadMarkerToLocation:newLocation];
}

@end
