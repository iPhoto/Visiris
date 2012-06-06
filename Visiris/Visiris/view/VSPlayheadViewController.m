//
//  VSPlayheadViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPlayheadViewController.h"
#import "VSPlayHeadView.h"

#import "VSCoreServices.h"

@interface VSPlayheadViewController ()

@property (strong) VSPlayHeadView *playHeadView;

@end

@implementation VSPlayheadViewController

@synthesize playHead        = _playHead;
@synthesize playHeadView    = _playHeadView;
@synthesize knobHeight      = _knobHeight;

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
    return newPosition;
}

-(BOOL) willStartMovingPlayHeadView:(VSPlayHeadView *)playheadView{
    return YES;
}

-(void) didStopMovingPlayHeadView:(VSPlayHeadView *)playheadView{
    
}

-(void) didMovePlayHeadView:(VSPlayHeadView *)playheadView{
    
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
