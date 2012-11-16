//
//  VSTimelineViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.08.12.
//
//

#import "VSTimelineViewController.h"

#import "VSTimelineScrollView.h"
#import "VSPlayHead.h"
#import "VSDocumentController.h"
#import "VSDocument.h"
#import "VSTrackViewController.h"

#import "VSCoreServices.h"


@interface VSTimelineViewController (){
    NSPoint _mouseDownPoint;
    BOOL _mouseDownOnView;
}

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
    self.scrollView.zoomingDelegate = self;
    self.scrollView.playheadMarkerDelegate = self;
    
    self.scrollView.trackHolderView.mouseEventsDelegate = self;
}


#pragma mark - VSViewKeyDownDelegate

-(void) view:(NSView *)view didReceiveKeyDownEvent:(NSEvent *)theEvent{
    if(theEvent){
        unichar keyCode = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
        
        switch (keyCode) {
            case 32:
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [VSDocumentController documentOfView:self.view]
                                                                     forKey:VSSendersDocumentKeyInUserInfoDictionary];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VSPlayKeyWasPressed
                                                                    object:nil
                                                                  userInfo:userInfo];
                break;
            }
            default:
                [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
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
    NSRect clipViewBounds = self.scrollView.contentView.bounds;
    clipViewBounds.origin.x -= ratio;
    
    [self.scrollView.contentView setBounds:clipViewBounds];
}

-(NSRect) timelineScrollView:(VSTimelineScrollView *)scrollView wantsToBeZoomedAccordingToScrollWheel:(float)amount atPosition:(NSPoint)mousePosition forCurrentFrame:(NSRect)currentFrame{
    if(amount == 0.0)// || self.trackHolder.frame.size.width < self.scrollView.documentVisibleRect.size.width)
        return currentFrame;
    
    NSRect newTrackHolderFrame = currentFrame;
    
    float zoomFactor = 1.0 + amount;
    
    float deltaWidth = self.scrollView.documentVisibleRect.size.width * zoomFactor -self.scrollView.documentVisibleRect.size.width;
    
    newTrackHolderFrame.size.width += deltaWidth;
    
    if(newTrackHolderFrame.size.width < self.scrollView.documentVisibleRect.size.width){
        newTrackHolderFrame.size.width = self.scrollView.documentVisibleRect.size.width;
    }
    
    return newTrackHolderFrame;
}

#pragma mark- VSViewResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    
    if(oldRect.size.width != newRect.size.width){
        [self computePixelTimeRatio];
    }
}


#pragma mark - VSPlayHeadRulerMarkerDelegate Implementation

-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    self.playhead.scrubbing = YES;
    return YES;
}

-(void) didMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    self.playhead.scrubbing = NO;
}

-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    double newTimePosition = [self timestampForPixelValue:location];
    self.playhead.currentTimePosition = newTimePosition;
    
    return location;
}

-(CGFloat) playHeadRulerMarker:(NSRulerMarker *)playheadMarker willJumpInContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    [self letPlayheadJumpOverDistance:location - [self currentPlayheadMarkerLocation]];
    
    return location;
}


#pragma mark -
#pragma mark VSViewMouseEventsDelegate Implementation

-(void) mouseDragged:(NSEvent *)theEvent onView:(NSView *)view{
    if([view isEqual:self.scrollView.trackHolderView]){
        if(_mouseDownOnView){
            NSPoint currentMousePosition = [self.scrollView.trackHolderView convertPoint:[theEvent locationInWindow] fromView:nil];
            
            
            NSRect selectionFrameRect;
            selectionFrameRect.origin.x =  fminf(_mouseDownPoint.x, currentMousePosition.x);
            selectionFrameRect.origin.y =  fminf(_mouseDownPoint.y, currentMousePosition.y);
            selectionFrameRect.size.width = fabs(_mouseDownPoint.x - currentMousePosition.x);
            selectionFrameRect.size.height = fabs(currentMousePosition.y - _mouseDownPoint.y);
            
            [self.scrollView.trackHolderView showSelectionFrame:selectionFrameRect];
            
            for (VSTrackViewController *trackViewController in self.trackViewControllers){
                NSRect intersectionRect = NSIntersectionRect(trackViewController.view.frame, selectionFrameRect);
                intersectionRect.origin.y = 0;
                [trackViewController selectionFrameIntersectsTrack:intersectionRect];
            }
        }
    }
}

-(void) mouseDown:(NSEvent *)theEvent onView:(NSView *)view{
    if([view isEqual:self.scrollView.trackHolderView]){
        _mouseDownOnView = YES;
        _mouseDownPoint = [self.scrollView.trackHolderView convertPoint:[theEvent locationInWindow] fromView:nil];
    }
}

-(void) mouseUp:(NSEvent *)theEvent onView:(NSView *)view{
    if([view isEqual:self.scrollView.trackHolderView]){
        _mouseDownOnView = NO;
        [self.scrollView.trackHolderView hideSelectionFrame];
    }
}

#pragma mark - Protected Methods

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

-(void) pixelTimeRatioDidChange{
    self.scrollView.trackHolderWidth = [self pixelForTimestamp:self.duration];
    [self setPlayheadMarkerLocation];
    self.scrollView.pixelTimeRatio = self.pixelTimeRatio;
}

-(void) letPlayheadJumpOverTheDefaultDistanceForward:(BOOL) forward{
    float deltaMove = 10;
    
    if(!forward)
        deltaMove *= -1;
    
    [self letPlayheadJumpOverDistance:deltaMove];
}

-(void) letPlayheadJumpOverDistance:(float) distance{
    
    if(distance == 0){
        return;
    }
    
    double newPixelPosition = self.currentPlayheadMarkerLocation + distance;
    double newTimePosition = [self timestampForPixelValue:newPixelPosition];
    
    [self scrollIfNewLocationOfPlayheadIsOutsideOfVisibleRect:newPixelPosition];
    
    self.playhead.currentTimePosition = newTimePosition;
    
    self.playhead.jumping = YES;
    self.playhead.jumping = NO;
}

-(void) scrollIfNewLocationOfPlayheadIsOutsideOfVisibleRect:(float) newLocation{
    NSPoint tmpPoint = NSMakePoint(newLocation, self.scrollView.documentVisibleRect.origin.y);
    
    //if the new position of the playhead marker is outside of the visible area of the timeline, the timeline is scrolled to the new position of the playhead marker
    if(! NSPointInRect(tmpPoint, self.scrollView.documentVisibleRect)){
        
        NSPoint currentBoundsOrigin = self.scrollView.contentView.bounds.origin;
        currentBoundsOrigin.x = newLocation;
        
    }
}

-(void) setPlayheadMarkerLocation{
    CGFloat newLocation = [self pixelForTimestamp:self.playhead.currentTimePosition];
    
    [self.scrollView movePlayHeadMarkerToLocation:newLocation];
    [self scrollIfNewLocationOfPlayheadIsOutsideOfVisibleRect: newLocation];
}


@end
