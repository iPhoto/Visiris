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
@synthesize delegate = _delegate;
@synthesize openGLContext = _openGLContext;
@synthesize playBackController = _playBackController;

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
        [self.openGLView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        
        [self.openGLViewHolder addSubview:self.openGLView];
    }
}

#pragma mark - IBAction

- (IBAction)play:(NSButton *)sender {
    if([self delegateRespondsToSelector:@selector(play) ]){
        [self.delegate play];
    }
}

- (IBAction)stop:(NSButton *)sender {
    if([self delegateRespondsToSelector:@selector(stop) ]){
        [self.delegate stop];
    }
}

#pragma mark - VSPlaybackControllerDelegate implementation

-(void) texture:(GLuint)theTexture isReadyForTimestamp:(double)theTimestamp{
    self.openGLView.texture = theTexture;
}

#pragma mark - Private Methods

-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSPreviewViewControllerDelegate) ]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    
    return NO;
}


-(void) setPlayBackController:(VSPlaybackController *)playBackController{

    self.openGLView.playBackcontroller = playBackController;
    
    _playBackController = playBackController;
}

-(VSPlaybackController*) playBackController{
    return _playBackController;
}




@end
