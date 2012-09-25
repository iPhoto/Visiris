//
//  VSAnimationTrackView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewResizingDelegate.h"
@interface VSAnimationTrackView : NSView

@property NSColor *trackColor;
@property id<VSViewResizingDelegate> delegate;
@property NSArray *keyFrameConnectionPaths;
@end
