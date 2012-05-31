//
//  VSPreviewViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPreviewViewController.h"
#import "VSPlaybackController.h"
#import "VSPreviewOpenGLView.h"

@interface VSPreviewViewController ()

@property (strong) VSPreviewOpenGLView *openGLView;

@end

@implementation VSPreviewViewController
@synthesize openGLViewHolder = _openGLViewHolder;
@synthesize openGLView = _openGLView;

@synthesize playbackController = _playbackController;
@synthesize openGLContext = _openGLContext;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSPreviewView";

#pragma mark - Init


-(id) initWithDefaultNibForOpenGLContext:(NSOpenGLContext *)theOpenGLContext{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.openGLContext = theOpenGLContext;
    
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma  mark - VSViewController

-(void) awakeFromNib{
    if(self.view){
        self.openGLView = [[VSPreviewOpenGLView alloc] initWithFrame:[self.openGLViewHolder frame] shareContext:self.openGLContext];
        
        [self.openGLViewHolder addSubview:self.openGLView];
    }
}

- (IBAction)play:(NSButton *)sender {
    [self.playbackController startPlaybackFromCurrentTimeStamp];
}

- (IBAction)stop:(NSButton *)sender {
    [self.playbackController stopPlayback];
}


@end
