//
//  VSTrackHolderView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackHolderView.h"

#import "VSTimelineGuideLine.h"

#import "VSCoreServices.h"

@interface VSTrackHolderView()

@property (strong) NSRulerMarker *playheadMarker;

@property (strong) VSTimelineGuideLine *guideLine;

@property NSPoint scrollOffset;

@end

@implementation VSTrackHolderView

@synthesize playheadMarker          = _playheadMarker;
@synthesize guideLine               = _guideLine;
@synthesize scrollOffset            = _scrollOffset;
@synthesize playheadMarkerDelegate  = _playheadMarkerDelegate;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:nil];
    
    self.scrollOffset = NSZeroPoint;
    
    [self setWantsLayer:YES];
    
    [self initEnclosingScrollView];
    [self initPlayheadMarker];
    
    [self initGuideLine];
}

-(void) initGuideLine{
    self.guideLine = [[VSTimelineGuideLine alloc] initWithFrame:self.frame];
    
    [self addSubview:self.guideLine];
    [self.guideLine setWantsLayer:YES];
    [self.guideLine.layer setZPosition:100];
    
    [self updateGuideline];
}

-(void) initEnclosingScrollView{
    
    [self.enclosingScrollView setHasHorizontalRuler:YES];
    [self.enclosingScrollView setHasVerticalRuler:YES];
    [self.enclosingScrollView setRulersVisible:YES];
    
    [self.enclosingScrollView.horizontalRulerView setClientView:self];
    [self.enclosingScrollView.verticalRulerView setClientView:self];
}

-(void) initPlayheadMarker{
    if(self.enclosingScrollView){
        
        NSImage *markerImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"playhead" ofType:@"png"]]; 
        
        self.playheadMarker = [[NSRulerMarker alloc] initWithRulerView:self.enclosingScrollView.horizontalRulerView markerLocation:0 image:markerImage imageOrigin:NSMakePoint(markerImage.size.width / 2, 0)];
        
        [self.enclosingScrollView.horizontalRulerView addMarker:self.playheadMarker];
        
    }
}


#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect{
    [self.guideLine setFrame:[self convertRect:dirtyRect toView:self.guideLine]];
    [self updateGuideline];
}


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
    
}

#pragma mark - Methods

-(void) setPlayHeadMarkerToLocation:(CGFloat)location{
    [self.playheadMarker setMarkerLocation:location];
    
    [self updateGuideline];
    
    [self.enclosingScrollView.horizontalRulerView setNeedsDisplayInRect:self.playheadMarker.imageRectInRuler];
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

#pragma mark - Private Methods

-(void) boundsDidChange:(NSNotification*) notification{
    
    
    if(notification.object == self.enclosingScrollView.contentView){
    
    NSInteger xOffset = self.enclosingScrollView.contentView.bounds.origin.x - self.frame.origin.x;
    NSInteger yOffset = self.enclosingScrollView.contentView.bounds.origin.y - self.frame.origin.y;
    
    self.scrollOffset = NSMakePoint(xOffset, yOffset);
    
    
    [self updateGuideline];
    }
    
}

-(void) updateGuideline{
    [self updateGuidelineAtMarkerLocation:self.playheadMarker.markerLocation];
}

-(void) updateGuidelineAtMarkerLocation:(CGFloat) location{
    NSRect newFrame = self.bounds; 
    newFrame.size = self.enclosingScrollView.contentSize;
    newFrame.origin.x += self.scrollOffset.x;
    newFrame.origin.y += self.scrollOffset.y;
    //  newFrame = [self convertRect:newFrame toView:self.guideLine];
    
    [self.guideLine setFrame:newFrame];
    
    NSPoint startPoint = [self convertPoint:self.playheadMarker.imageRectInRuler.origin toView:self.guideLine];
    startPoint.x = location - self.scrollOffset.x;
    startPoint.y += self.scrollOffset.y;
    
    self.guideLine.lineStartPoint = startPoint;
    
    [self.guideLine setNeedsDisplay:YES];
}



@end
