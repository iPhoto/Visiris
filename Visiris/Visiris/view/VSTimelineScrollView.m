//
//  VSTimelineScrollView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineScrollView.h"

#import "VSTrackHolderView.h"
#import "VSTimelineRulerView.h"
#import "VSPlayheadMarker.h"
#import "VSTrackLabelsRulerView.h"

#import "VSCoreServices.h"






@interface VSTimelineScrollView()
@property VSTimelineRulerView *timelineRulerView;
@property VSPlayheadMarker *playheadMarker;
@property VSTrackLabelsRulerView *trackLabelRulerView;
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
    [self initRulers];
    [self initPlayheadMarker];
}

-(void) initDocumentView{
    self.trackHolderView = [[VSTrackHolderView alloc] init];
    self.documentView = self.trackHolderView;
    self.trackHolderView.trackHolderViewDelegate = self;
    
    [self.trackHolderView setAutoresizingMask:NSViewNotSizable];
    [self.trackHolderView setWantsLayer:YES];
    [self.contentView.layer addSublayer:self.trackHolderView.layer];
    [self.contentView setWantsLayer:YES];
}

/**
 * Inits the views enclosing scrollView and its rulers
 */
-(void) initRulers{
    
    [self setHasHorizontalRuler:YES];
    [self setHasVerticalRuler:YES];
    [self setRulersVisible:YES];
    
    self.timelineRulerView = [[VSTimelineRulerView alloc] initWithScrollView:self orientation:NSHorizontalRuler];
    [self setHorizontalRulerView:self.timelineRulerView];
    
    
    self.trackLabelRulerView = [[VSTrackLabelsRulerView alloc] initWithScrollView:self orientation:NSVerticalRuler];
    self.trackLabelRulerView.clientView = self.trackHolderView;
    self.verticalRulerView = self.trackLabelRulerView;
    self.hasVerticalRuler = YES;
    self.rulersVisible = YES;

    
    
    [self.horizontalRulerView setClientView:self.trackHolderView];
    [self.verticalRulerView setClientView:self.trackHolderView];
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
        if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wantsToBeZoomedAccordingToScrollWheel:atPosition:)]){
            [self.zoomingDelegate timelineScrollView:self wantsToBeZoomedAccordingToScrollWheel:[theEvent deltaY] atPosition:[theEvent locationInWindow]];
        }
    }
}

-(void) magnifyWithEvent:(NSEvent *)event{
    
    if([self zoomingDelegateImplementsSelector:@selector(timelineScrollView:wantsToBeZoomedAccordingToScrollWheel:atPosition:)]){
        [self.zoomingDelegate timelineScrollView:self wantsToBeZoomedAccordingToScrollWheel:[event magnification] atPosition:[event locationInWindow]];
    }
}

#pragma mark - VSTrackHolderViewDelegate Implementaion

-(BOOL) shouldMoveMarker:(NSRulerMarker *)marker inTrackHolderView:(VSTrackHolderView *)trackHolderView{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(shouldMovePlayHeadRulerMarker:inContainingView:)]){
            return [self.playheadMarkerDelegate shouldMovePlayHeadRulerMarker:self.playheadMarker inContainingView:trackHolderView];
        }
    }
    
    return NO;
}
-(void) didMoveRulerMarker:(NSRulerMarker *)marker inTrackHolderView:(VSTrackHolderView *)trackHolderView{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(didMovePlayHeadRulerMarker:inContainingView:)]){
            [self.playheadMarkerDelegate didMovePlayHeadRulerMarker:self.playheadMarker inContainingView:trackHolderView];
        }
    }
}

-(CGFloat) willMoveRulerMarker:(NSRulerMarker *)marker inTrackHolderView:(VSTrackHolderView *)trackHolderView toLocation:(CGFloat)location{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(willMovePlayHeadRulerMarker:inContainingView:toLocation:)]){
            location = [self.playheadMarkerDelegate willMovePlayHeadRulerMarker:marker inContainingView:trackHolderView toLocation:location];
        }
    }
    
    float newGuidelinPosition = location +self.playheadMarker.imageOrigin.x - self.timelineRulerView.originOffset;
    [self.trackHolderView moveGuidelineToPosition:newGuidelinPosition];
    
    return location;
}

-(CGFloat) mouseDownOnRulerView:(NSRulerView *)rulerView atLocation:(CGFloat)location{
    if([self delegateRespondsToSelector:@selector(playHeadRulerMarker:willJumpInContainingView:toLocation:)]){
        location = [self.playheadMarkerDelegate playHeadRulerMarker:self.playheadMarker willJumpInContainingView:self.trackHolderView toLocation:location];
    }
    
    float newGuidelinPosition = self.playheadMarker.imageRectInRuler.origin.x +self.playheadMarker.imageOrigin.x - self.timelineRulerView.originOffset;
    
    [self.trackHolderView moveGuidelineToPosition:newGuidelinPosition];
    
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

-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel{
    [self.trackLabelRulerView addTrackLabel:aTrackLabel];
}

-(void) addTrackView:(NSView *)aTrackView{
    [self.trackHolderView addSubview:aTrackView];
    [self.trackHolderView.layer addSublayer:aTrackView.layer];
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

@end
