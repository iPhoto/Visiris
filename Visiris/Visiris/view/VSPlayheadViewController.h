//
//  VSPlayheadViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSPlayHeadView.h"

@class VSPlayHead;

@interface VSPlayheadViewController : NSViewController<VSPlayHeadViewDelegate>

@property VSPlayHead *playHead;

@property NSInteger knobHeight;

-(id) initWithPlayHead:(VSPlayHead*) playHead forFrame:(NSRect) frame;

@end
