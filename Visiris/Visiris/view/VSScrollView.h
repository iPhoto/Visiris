//
//  VSScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 11.09.12.
//
//

#import <Cocoa/Cocoa.h>

@protocol VSScrollViewScrollingDelegate <NSObject>

-(BOOL) scrollView:(NSScrollView*) scrollView willBeScrolledByScrollWheelEvent:(NSEvent*) scrollEvent;

-(void) scrollView:(NSScrollView*) scrollView changedBoundsFrom:(NSRect) fromBounds to:(NSRect) toBounds;

@end


@interface VSScrollView : NSScrollView

@property id<VSScrollViewScrollingDelegate> scrollingDelegate;

-(void) setBoundsOriginWithouthNotifiying:(NSPoint) boundsOrigin;

@end
