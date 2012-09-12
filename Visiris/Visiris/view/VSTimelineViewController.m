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

#pragma mark- VSTimelineViewDelegate implementation

-(void) viewDidResizeFromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    
    if(oldFrame.size.width != newFrame.size.width){
        
        NSRect newDocumentFrame = [self.timelineScrollView.trackHolderView frame];
        
        //updates the width according to how the width of the view has been resized
        newDocumentFrame.size.width += newFrame.size.width - oldFrame.size.width;
        [self.timelineScrollView.trackHolderView setFrame:(newDocumentFrame)];
        [self computePixelTimeRatio];
    }
}

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
    
}

-(NSRect) timelineScrollView:(VSTimelineScrollView *)scrollView wantsToBeZoomedAccordingToScrollWheel:(float)amount atPosition:(NSPoint)mousePosition forCurrentFrame:(NSRect)currentFrame{
    return currentFrame;
}


#pragma mark - Methods

-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

-(double) pixelForTimestamp:(double) timestamp{
    return timestamp / self.pixelTimeRatio;
}

-(void) computePixelTimeRatio{
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
