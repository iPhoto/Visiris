//
//  VSPlayHeadView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSPlayHeadView;

@protocol VSPlayHeadViewDelegate <NSObject>

-(NSPoint) willMovePlayHeadView:(VSPlayHeadView*) playheadView FromPosition:(NSPoint) oldPosition toPosition:(NSPoint) newPosition;

-(void) didMovePlayHeadView:(VSPlayHeadView*) playheadView;

-(BOOL) willStartMovingPlayHeadView:(VSPlayHeadView*) playheadView;

-(void) didStopMovingPlayHeadView:(VSPlayHeadView*) playheadView;

@end

@interface VSPlayHeadView : NSView

@property NSInteger knobHeight;

@property id<VSPlayHeadViewDelegate> delegate;

@property BOOL moving;

@property NSPoint formerMousePosition;

@end
