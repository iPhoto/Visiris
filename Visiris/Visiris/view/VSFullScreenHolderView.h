//
//  VSFullScreenHolderView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 03.10.12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSViewKeyDownDelegate.h"

@interface VSFullScreenHolderView : NSView

@property (strong) id<VSViewKeyDownDelegate> keyDownDelegate;

@end
