//
//  VSKeyFrameView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 14.09.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSViewMouseEventsDelegate.h"

@interface VSKeyFrameView : NSView

@property id<VSViewMouseEventsDelegate> mouseDelegate;

@property BOOL moving;
@property BOOL selected;

@end
