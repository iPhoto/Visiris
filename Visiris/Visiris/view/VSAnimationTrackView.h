//
//  VSAnimationTrackView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewResizingDelegate.h"

/**
 * Subclass of NSView representing the animation of one VSParameter
 *
 * Stores a NSKeyFrameView for every VSKeyFrame of the VSParameter as subview
 */
@interface VSAnimationTrackView : NSView

/** Background-Color of the view */
@property (strong) NSColor *trackColor;

/** Stores the connection between the keyframes of the track */
@property (weak) NSArray *keyFrameConnectionPaths;
@end
