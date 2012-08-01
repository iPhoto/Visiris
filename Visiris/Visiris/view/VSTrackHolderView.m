//
//  VSTrackHolderView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackHolderView.h"

#import "VSTimelineRulerView.h"
#import "VSPlayheadMarker.h"

#import "VSCoreServices.h"

@interface VSTrackHolderView()

/** VSPlayheadMarker represanting the Playhead in the horizontal rulerview */
@property (strong) VSPlayheadMarker *playheadMarker;


/** current offset of view's enclosing scrollView */
@property NSPoint scrollOffset;

@property (strong) CALayer *guideLine;

@property (strong) VSTimelineRulerView *timelineRulerView;

@end

@implementation VSTrackHolderView

@synthesize playheadMarker          = _playheadMarker;
@synthesize scrollOffset            = _scrollOffset;
@synthesize playheadMarkerDelegate  = _playheadMarkerDelegate;
@synthesize guideLine               = _guideLayer;
@synthesize playheadMarkerLocation  = _playheadMarkerLocation;
@synthesize timelineRulerView       = _timelineRulerView;
@synthesize pixelTimeRatio          = _pixelTimeRatio;

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    self.scrollOffset = NSZeroPoint;
    
    [self initLayer];
    [self initEnclosingScrollView];
    [self initPlayheadMarker];
    [self initGuideLine];
    [self initObservers];
}

/**
 * Inits the observers of the view
 */
- (void)initObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:nil];
}

/**
 * Inits the views layer
 */
- (void)initLayer {
    [self setWantsLayer:YES];
    self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
}

/**
 * Inits the guideline and sets its position
 */
-(void) initGuideLine{
    
    self.guideLine = [[CALayer alloc] init];
    self.guideLine.backgroundColor = [[NSColor blueColor] CGColor];
    [self.guideLine setZPosition:30];
    [self.layer addSublayer:self.guideLine];
}

/**
 * Inits the views enclosing scrollView and its rulers
 */
-(void) initEnclosingScrollView{
    
    [self.enclosingScrollView setHasHorizontalRuler:YES];
    [self.enclosingScrollView setHasVerticalRuler:YES];
    [self.enclosingScrollView setRulersVisible:YES];
    
    
    self.timelineRulerView = [[VSTimelineRulerView alloc] initWithScrollView:self.enclosingScrollView orientation:NSHorizontalRuler];
    
    self.timelineRulerView.originOffset = 80;// NSMaxX(self.enclosingScrollView.verticalRulerView.frame);
    
    [self.enclosingScrollView setHorizontalRulerView:self.timelineRulerView];
    
    
    
    
    
    [self.enclosingScrollView.horizontalRulerView setClientView:self];
    [self.enclosingScrollView.verticalRulerView setClientView:self];
}

/**
 * Inits the marker representing the playhead for the horizontal ruler of enclosing scroll view.
 */
-(void) initPlayheadMarker{
    if(self.enclosingScrollView){
        
        NSImage *markerImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"playhead" ofType:@"png"]]; 
        
        self.playheadMarker = [[VSPlayheadMarker alloc] initWithRulerView:self.enclosingScrollView.horizontalRulerView markerLocation:0 image:markerImage imageOrigin:NSMakePoint(markerImage.size.width / 2,0)];
        
        [self.enclosingScrollView.horizontalRulerView addMarker:self.playheadMarker];
        
    }
}


#pragma mark - NSView

-(BOOL) isFlipped{
    return YES;
}


#pragma mark - RulerViewDelegate

-(void) rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker{
    if(marker == self.playheadMarker){
        [self updateGuideline];
        
        if([self delegateRespondsToSelector:@selector(didMovePlayHeadRulerMarker:inContainingView:)]){
            [self.playheadMarkerDelegate didMovePlayHeadRulerMarker:self.playheadMarker inContainingView:self];
        }
    }
}

-(BOOL) rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker{
    if(marker == self.playheadMarker){
        if([self delegateRespondsToSelector:@selector(shouldMovePlayHeadRulerMarker:inContainingView:)]){
            return [self.playheadMarkerDelegate shouldMovePlayHeadRulerMarker:self.playheadMarker inContainingView:self];
        }
    }
    return NO;
}

-(CGFloat) rulerView:(NSRulerView *)ruler willMoveMarker:(NSRulerMarker *)marker toLocation:(CGFloat)location{
    if(marker == self.playheadMarker){
        if ([self delegateRespondsToSelector:@selector(willMovePlayHeadRulerMarker:inContainingView:toLocation:)]) {
            location = [self.playheadMarkerDelegate willMovePlayHeadRulerMarker:self.playheadMarker inContainingView:self
                                                                     toLocation:location];
        }
    }
    
    [self updateGuidelineAtMarkerLocation:location];
    
    return location;
}

-(void) rulerView:(NSRulerView *)ruler handleMouseDown:(NSEvent *)event{
    if(ruler == self.enclosingScrollView.horizontalRulerView){
        NSPoint pointInView = [self.window.contentView convertPoint:[event locationInWindow] toView:self.enclosingScrollView.horizontalRulerView];
        
        
        
        CGFloat location = pointInView.x-self.playheadMarker.imageOrigin.x; //pointInView.x - self.playheadMarker.imageRectInRuler.size.width / 2 - self.playheadMarker.imageOrigin.x+self.scrollOffset.x;
        
        if([self delegateRespondsToSelector:@selector(playHeadRulerMarker:willJumpInContainingView:toLocation:)]){
            location = [self.playheadMarkerDelegate playHeadRulerMarker:self.playheadMarker willJumpInContainingView:self toLocation:location];
        }
        
    [self movePlayHeadMarkerToLocation:location];
        [self.enclosingScrollView.horizontalRulerView setNeedsDisplay:YES];
    }
}


#pragma mark - Methods

-(void) movePlayHeadMarkerToLocation:(CGFloat)location{
    CGFloat oldLocation = self.playheadMarker.markerLocation;
    if(location != self.playheadMarker.markerLocation){
        
        NSRect formerImageRect = self.playheadMarker.imageRectInRuler;
        [self.playheadMarker setMarkerLocation:location];
        
//        [self updateGuideline];
        
        [self.enclosingScrollView.horizontalRulerView setNeedsDisplayInRect:self.playheadMarker.imageRectInRuler];
        [self.enclosingScrollView.horizontalRulerView setNeedsDisplayInRect:formerImageRect];
        
        [self.timelineRulerView moveRulerlineFromLocation:oldLocation toLocation:location];
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
 * Receiver of the NSViewBoundsDidChangeNotification. Updates the scrollOffset and tells the guideline to be updated
 * @param notification NSNotification of the NSViewBoundsDidChangeNotification
 */
-(void) boundsDidChange:(NSNotification*) notification{
    if(notification.object == self.enclosingScrollView.contentView){
        [self updateScrollOffset];
        [self updateGuideline];
    }
    
}

/**
 * Updates the playhead marker at its current location
 */
-(void) updateGuideline{
    [self updateGuidelineAtMarkerLocation:self.playheadMarker.markerLocation];
}

/**
 * Updates the guideline for the given location
 * @param location Location the guidelin is updated for
 */
-(void) updateGuidelineAtMarkerLocation:(CGFloat) location{
    NSRect layerRect = self.frame;
    
    layerRect.size.width = 1;
    layerRect.origin.x = round(self.playheadMarker.imageRectInRuler.origin.x+self.scrollOffset.x);
    layerRect.origin.y = 0;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self.guideLine setFrame:NSIntegralRect(layerRect)];
    [CATransaction commit];
    
    
}

/**
 * Stores the current scrollOffset in the scrollOffset-Property
 */
-(void) updateScrollOffset{
    NSInteger xOffset = self.enclosingScrollView.contentView.bounds.origin.x - self.frame.origin.x;
    NSInteger yOffset = self.enclosingScrollView.contentView.bounds.origin.y - self.frame.origin.y;
    
    self.scrollOffset = NSMakePoint(xOffset, yOffset);
}

#pragma mark - Properties

-(CGFloat) playheadMarkerLocation{
    return self.playheadMarker.markerLocation;
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

@end
