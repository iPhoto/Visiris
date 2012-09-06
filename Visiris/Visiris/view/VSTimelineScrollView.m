//
//  VSTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineScrollView.h"

#import "VSMainTimelineContentView.h"
#import "VSTimelineRulerView.h"
#import "VSPlayheadMarker.h"
#import "VSTrackLabelsRulerView.h"

#import "VSCoreServices.h"

@interface VSTimelineScrollView()

/** Subclass of NSRulerView, displaying the timecode above the timeline */
@property VSTimelineRulerView *timelineRulerView;

/** Subclass of NSRulerMarker Displaying the current Position of the playhead in the timelineRulerView */
@property VSPlayheadMarker *playheadMarker;

@end

@implementation VSTimelineScrollView
@synthesize zoomingDelegate = _zoomingDelegate;
@synthesize pixelTimeRatio = _pixelTimeRatio;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(void) awakeFromNib{
    [self initDocumentView];
    [self initTimelineRuler];
    [self initPlayheadMarker];
    
    [self.trackHolderView setFrame:NSMakeRect(0, 0, self.visibleTrackViewsHolderWidth, self.frame.size.height)];
}

-(void) initDocumentView{
    self.documentView = self.trackHolderView;
    self.trackHolderView.trackHolderViewDelegate = self;
    
    [self.contentView setWantsLayer:YES];
    [self.contentView.layer addSublayer:self.trackHolderView.layer];
       
}

/**
 * Inits the views enclosing scrollView and its rulers
 */
-(void) initTimelineRuler{
    
    [self setHasHorizontalRuler:NO];
    [self setHasVerticalRuler:YES];
    [self setRulersVisible:YES];
    
    self.timelineRulerView = [[VSTimelineRulerView alloc] initWithScrollView:self orientation:NSHorizontalRuler];
    [self setHorizontalRulerView:self.timelineRulerView];

    
    [self.horizontalRulerView setClientView:self.trackHolderView];
    
}

/**
 * Inits the marker representing the playhead for the horizontal ruler of enclosing scroll view.
 */
-(void) initPlayheadMarker{
    NSImage *markerImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"playhead" ofType:@"png"]];
    
    self.playheadMarker = [[VSPlayheadMarker alloc] initWithRulerView:self.timelineRulerView markerLocation:0 image:markerImage imageOrigin:NSMakePoint(markerImage.size.width / 2,0)];
    
    [self.timelineRulerView addMarker:self.playheadMarker];
}

#pragma mark - Mouse Events

-(void) scrollWheel:(NSEvent *)theEvent{
    if(!([theEvent modifierFlags] & NSCommandKeyMask)){
        [super scrollWheel:theEvent];
    }
    else {
        [self zoom:[theEvent deltaY]  atPosition: [self.trackHolderView convertPoint:[theEvent locationInWindow] fromView:nil]];
    }
}

-(void) magnifyWithEvent:(NSEvent *)event{
    [self zoom:[event magnification]  atPosition:[self.trackHolderView convertPoint:[event locationInWindow] fromView:nil]];
}

#pragma mark - VSTrackHolderViewDelegate Implementaion

-(BOOL) shouldMoveMarker:(NSRulerMarker *)marker inTrackHolderView:(VSMainTimelineContentView *)trackHolderView{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(shouldMovePlayHeadRulerMarker:inContainingView:)]){
            return [self.playheadMarkerDelegate shouldMovePlayHeadRulerMarker:self.playheadMarker inContainingView:trackHolderView];
        }
    }
    
    return NO;
}
-(void) didMoveRulerMarker:(NSRulerMarker *)marker inTrackHolderView:(VSMainTimelineContentView *)trackHolderView{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(didMovePlayHeadRulerMarker:inContainingView:)]){
            [self.playheadMarkerDelegate didMovePlayHeadRulerMarker:self.playheadMarker inContainingView:trackHolderView];
        }
    }
}

-(CGFloat) willMoveRulerMarker:(NSRulerMarker *)marker inTrackHolderView:(VSMainTimelineContentView *)trackHolderView toLocation:(CGFloat)location{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(willMovePlayHeadRulerMarker:inContainingView:toLocation:)]){
            location = [self.playheadMarkerDelegate willMovePlayHeadRulerMarker:marker inContainingView:trackHolderView toLocation:location];
        }
    }
    
    return location;
}

-(CGFloat) mouseDownOnRulerView:(NSRulerView *)rulerView atLocation:(CGFloat)location{
    if([self delegateRespondsToSelector:@selector(playHeadRulerMarker:willJumpInContainingView:toLocation:)]){
        location = [self.playheadMarkerDelegate playHeadRulerMarker:self.playheadMarker willJumpInContainingView:self.trackHolderView toLocation:location];
    }
    
    [self.playheadMarker setMarkerLocation:location];
    
    return location;
}

#pragma mark - Methods

-(void) movePlayHeadMarkerToLocation:(CGFloat)location{
    if(location != self.playheadMarker.markerLocation){
        NSRect formerImageRect = self.playheadMarker.imageRectInRuler;
        [self.playheadMarker setMarkerLocation:location];
        
        float newGuidelinPosition = self.playheadMarker.imageRectInRuler.origin.x +self.playheadMarker.imageOrigin.x - self.timelineRulerView.originOffset;
        
        [self.trackHolderView moveGuidelineToPosition:newGuidelinPosition];
        
        [self.timelineRulerView setNeedsDisplayInRect:self.playheadMarker.imageRectInRuler];
        [self.timelineRulerView setNeedsDisplayInRect:formerImageRect];
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate  is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.playheadMarkerDelegate){
        if([self.playheadMarkerDelegate conformsToProtocol:@protocol(VSPlayHeadRulerMarkerDelegate)]){
            if([self.playheadMarkerDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) zoomingDelegateImplementsSelector:(SEL) selector{
    if(self.zoomingDelegate){
        if([self.zoomingDelegate conformsToProtocol:@protocol(VSTimelineScrollViewZoomingDelegate) ]){
            if([self.zoomingDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

/**
 * Translates the given pixel value to a timestamp according to the pixelTimeRation
 * @param pixelPosition Value in pixels the timestamp is computed for
 * @return Timestamp for the given pixel position
 */
-(double) timestampForPixelValue:(double) pixelPosition{
    return pixelPosition * self.pixelTimeRatio;
}

/**
 * Transletes the given timestamp to a pixel value according to the pixelTimeRation
 * @param timestamp Timestamp the pixel position is computed for
 * @return Pixelposition for the given Timestamp
 */
-(double) pixelForTimestamp:(double) timestamp{
    return timestamp / self.pixelTimeRatio;
}

/**
 * Calls the zoomingDelgate and informs it about the zooming-operation
 * @param zoomValue Amount of zooming
 * @param position NSPoint where the zoom-Operatino is happening onto the view
 */
-(void) zoom:(float) zoomValue atPosition:(NSPoint) position{
    if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wantsToBeZoomedAccordingToScrollWheel:atPosition:forCurrentFrame:)]){
        
        [self.trackHolderView setFrame:[self.zoomingDelegate timelineScrollView:self wantsToBeZoomedAccordingToScrollWheel:zoomValue atPosition:position forCurrentFrame:self.trackHolderView.frame]];
        
        if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wasZoomedAtPosition:)]){
            [self.zoomingDelegate timelineScrollView:self wasZoomedAtPosition:position];
        }
    }
}


-(void) addTrackView:(NSView *)aTrackView{
    [self.trackHolderView addSubview:aTrackView];
    [self.trackHolderView.layer addSublayer:aTrackView.layer];
    
    NSRect tmp = [[[self.trackHolderView subviews] objectAtIndex:0] frame];
    
    for(NSView *subView in self.trackHolderView.subviews){
        tmp = NSUnionRect(tmp, subView.frame);
    }
    
    [self.trackHolderView setFrameSize:NSMakeSize(self.documentVisibleRect.size.width, tmp.size.height)];
}

#pragma mark - Properties

-(void) setPixelTimeRatio:(double)pixelTimeRatio{
    if (_pixelTimeRatio != pixelTimeRatio) {
        self.timelineRulerView.pixelTimeRatio = pixelTimeRatio;
    }
    _pixelTimeRatio = pixelTimeRatio;
}

-(double) pixelTimeRatio{
    return _pixelTimeRatio;
}

-(float) playheadMarkerLocation{
    return self.playheadMarker.markerLocation;
}

-(float) visibleTrackViewsHolderWidth{
    return self.documentVisibleRect.size.width - self.verticalScroller.frame.size.width + self.verticalRulerView.frame.size.width;
}

-(float) trackHolderWidth{
    return self.trackHolderView.frame.size.width;
}


-(void) setTrackHolderWidth:(float)trackHolderWidth{
    [self.trackHolderView setFrameSize:NSMakeSize(trackHolderWidth, self.trackHolderView.frame.size.height)];
}

-(CGFloat) timelecodeRulerThickness{
    return self.timelineRulerView.ruleThickness;
}



@end
