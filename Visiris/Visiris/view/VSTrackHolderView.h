//
//  VSTrackHolderView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol VSPlayHeadRulerMarkerDelegate <NSObject>
    
-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

-(void) didMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView;

-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker*) playheadMarker inContainingView:(NSView*) aView toLocation:(CGFloat) location;

@end

@interface VSTrackHolderView : NSView

@property id<VSPlayHeadRulerMarkerDelegate> playheadMarkerDelegate;

@end
