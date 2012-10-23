//
//  VSTrackHolderView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineScrollViewDocumentView.h"

#import <QuartzCore/QuartzCore.h>

#import "VSTimelineRulerView.h"
#import "VSPlayheadMarker.h"
#import "VSAnimationTimelineScrollViewDocumentView.h"

#import "VSCoreServices.h"

@interface VSTimelineScrollViewDocumentView()

/** current offset of view's enclosing scrollView */
@property NSPoint scrollOffset;

/** CALayer to draw a guideline for the current position of the playheadmarker above the view */
@property (strong) CALayer *guideLine;

@end



@implementation VSTimelineScrollViewDocumentView


#pragma mark - Init


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setViewsProperties];
    }
    
    return self;
}

/**
 * Inits the observers of the view
 */
- (void)initObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:nil];
}

/**
 * Inits the views layer
 */
- (void)initLayer {
    [self setWantsLayer:YES];
    [self.layer setZPosition:20];
    self.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
}

/**
 * Inits the guideline and sets its position
 */
-(void) initGuideLine{
    
    
    
    self.guideLine = [[CALayer alloc] init];
    self.guideLine.backgroundColor = [[NSColor playheadGuiderColor] CGColor];
    [self.guideLine setZPosition:10];
    
    [self.layer addSublayer:self.guideLine];
    
    [self.layer removeAllAnimations];
    [self.guideLine removeAllAnimations];
    

    self.guideLine.delegate = self;
    
    NSRect layerRect = self.frame;
    layerRect.size.width = 1;
    layerRect.origin.x = 0;
    layerRect.origin.y = 0;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    [self.guideLine setFrame:NSIntegralRect(layerRect)];
    [CATransaction commit];
    


}

-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict{
    
}

#pragma mark - NSView

-(BOOL) isFlipped{
    return YES;
}

#pragma mark - Methods

-(void) setViewsProperties{
    self.scrollOffset = NSZeroPoint;
    
    [self initLayer];
    [self initGuideLine];
    [self initObservers];
}

-(void) moveGuidelineToPosition:(CGFloat) location{
    NSRect layerRect = self.frame;
    layerRect.size.width = 1;
    layerRect.origin.x = round(location+self.scrollOffset.x);
    layerRect.origin.y = 0;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self.guideLine setFrame:layerRect];
    [CATransaction commit];

    
    if([self isKindOfClass:[VSAnimationTimelineScrollViewDocumentView class]]){
//        DDLogInfo(@"guideline layerrect:%@", NSStringFromRect(layerRect));
    }
    
    
}


#pragma mark - RulerViewDelegate

-(void) rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker{
    if([self delegateRespondsToSelector:@selector(didMoveRulerMarker:inTrackHolderView:)]){
        [self.trackHolderViewDelegate didMoveRulerMarker:marker inTrackHolderView:self];
    }
}

-(BOOL) rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker{
    if([self delegateRespondsToSelector:@selector(shouldMoveMarker:inTrackHolderView:)]){
        return [self.trackHolderViewDelegate shouldMoveMarker:marker inTrackHolderView:self];
    }
    
    return NO;
}

-(CGFloat) rulerView:(NSRulerView *)ruler willMoveMarker:(NSRulerMarker *)marker toLocation:(CGFloat)location{
    
    if ([self delegateRespondsToSelector:@selector(willMoveRulerMarker:inTrackHolderView:toLocation:)]){
        location = [self.trackHolderViewDelegate willMoveRulerMarker:marker inTrackHolderView:self toLocation:location];
    }
    
    [self moveGuidelineToPosition:location-self.scrollOffset.x];
    
    
    return location;
}

-(void) rulerView:(NSRulerView *)ruler handleMouseDown:(NSEvent *)event{
    if(ruler == self.enclosingScrollView.horizontalRulerView){
        NSPoint pointInView = [self.window.contentView convertPoint:[event locationInWindow] toView:ruler];
        
        CGFloat location = pointInView.x-ruler.originOffset +self.scrollOffset.x;
        
        if([self delegateRespondsToSelector:@selector(mouseDownOnRulerView:atLocation:)]){
            location = [self.trackHolderViewDelegate mouseDownOnRulerView:ruler atLocation:location];
        }
    }
}

#pragma mark - Private Methods

/**
 * Checks if the delegate  is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.trackHolderViewDelegate){
        if([self.trackHolderViewDelegate conformsToProtocol:@protocol(VSTrackHolderViewDelegate)]){
            if([self.trackHolderViewDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

/*+
 * Called when NSViewBoundsDidChangeNotification is called
 * @param notification NSNotification send by the NSViewBoundsDidChangeNotification
 */
-(void) boundsDidChange:(NSNotification*) notification{
    if(notification.object == self.enclosingScrollView.contentView){
        [self updateScrollOffset];
    }
    
}

/**
 * Stores the current scrollOffset in the scrollOffset-Property
 */
-(void) updateScrollOffset{
    NSInteger xOffset = self.enclosingScrollView.contentView.bounds.origin.x - self.frame.origin.x;
    NSInteger yOffset = self.enclosingScrollView.contentView.bounds.origin.y - self.frame.origin.y;
    
    self.scrollOffset = NSMakePoint(xOffset, yOffset);
}


@end
