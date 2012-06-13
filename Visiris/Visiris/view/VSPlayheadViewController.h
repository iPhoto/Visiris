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

/** VSPlayHead the VSPlayheadViewController represents */
@property VSPlayHead *playHead;

@property NSInteger xOffset;

/** Height of the knob at the top of the view */
@property NSInteger knobHeight;

#pragma mark - Init

/**
 * Inits the VSPlayheadViewController with the given values
 * @param playHead VSPlayHead the VSPlayheadViewController represents
 * @return self
 */
-(id) initWithPlayHead:(VSPlayHead *)playHead;


#pragma mark - Methods

/**
 * Tells the VSPlayheadViewController to change its pixelItemRation and to update its view's position
 * @param newPixelItemRation Double value the ratio has been changed to
 */
-(void) changePixelItemRatio:(double) newPixelItemRatio;

@end
