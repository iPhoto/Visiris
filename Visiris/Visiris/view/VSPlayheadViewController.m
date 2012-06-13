 //
//  VSPlayheadViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlayheadViewController.h"
#import "VSPlayHeadView.h"
#import "VSPlayHead.h"

#import "VSCoreServices.h"

@interface VSPlayheadViewController ()

/** VSPlayHeadView VSPlayHeadViewController is responsible for. */
@property (strong) VSPlayHeadView *playHeadView;

/** Current ration between pixel and Time. The playHeadView is positioned according to it */
@property double pixelTimeRatio;

@end

@implementation VSPlayheadViewController

@synthesize playHead        = _playHead;
@synthesize playHeadView    = _playHeadView;
@synthesize knobHeight      = _knobHeight;
@synthesize pixelTimeRatio = _pixelTimeRation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithPlayHead:(VSPlayHead *)playHead forFrame:(NSRect)frame{
    if(self = [super init]){
        self.playHead = playHead;

        self.playHeadView = [[VSPlayHeadView alloc] initWithFrame:frame];
        self.view = self.playHeadView;
        self.playHeadView.delegate = self;
    }
    return self;
}



#pragma mark - VSPlayHeadViewDelegate

-(NSPoint) willMovePlayHeadView:(VSPlayHeadView *)playheadView FromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition{
    if(newPosition.x < 0){
        return NSMakePoint(0, newPosition.y);
    }
    return newPosition;
}

-(BOOL) willStartMovingPlayHeadView:(VSPlayHeadView *)playheadView{
    return YES;
}

-(void) didStopMovingPlayHeadView:(VSPlayHeadView *)playheadView{
    
}

-(void) didMovePlayHeadView:(VSPlayHeadView *)playheadView{
    double newTimePosition = NSMidX(self.view.frame) * self.pixelTimeRatio;
    self.playHead.currentTimePosition = newTimePosition;
}

-(void) changePixelItemRatio:(double)newPixelItemRatio{
    if(newPixelItemRatio != self.pixelTimeRatio){
        self.pixelTimeRatio = newPixelItemRatio;
        
        [self positionPlayHeadView];
    }
}

-(void) positionPlayHeadView{
    NSRect newFrame = self.view.frame;
    newFrame.origin.x = self.playHead.currentTimePosition / self.pixelTimeRatio;
    [self.view setFrame:newFrame];
}

#pragma mark - Properties

-(void) setKnobHeight:(NSInteger)knobHeight{
    if(knobHeight != _knobHeight){
        _knobHeight = knobHeight;
        self.playHeadView.knobHeight = _knobHeight;
    }
}

-(NSInteger) knobHeight{
    return _knobHeight;
}

@end
