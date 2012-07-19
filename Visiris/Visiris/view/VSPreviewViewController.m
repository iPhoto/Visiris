//
//  VSPreviewViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPreviewViewController.h"

#import "VSPlaybackController.h"
#import "VSPreviewView.h"
#import "VSProjectSettings.h"

#import "VSCoreServices.h"



@interface VSPreviewViewController ()

@property NSInteger openGLViewMarginTop;
@property NSInteger openGLViewMarginBottom;
@property NSInteger openGLViewMarginLeft;
@property NSInteger openGLViewMarginRight;

@end

@implementation VSPreviewViewController

@synthesize openGLViewHolder        = _openGLViewHolder;
@synthesize openGLView              = _openGLView;
@synthesize delegate                = _delegate;
@synthesize openGLContext           = _openGLContext;
@synthesize playBackController      = _playBackController;
@synthesize openGLViewMarginTop     = _openGLViewMarginTop;
@synthesize openGLViewMarginBottom  = _openGLViewMarginBottom;
@synthesize openGLViewMarginLeft    = _openGLViewMarginLeft;
@synthesize openGLViewMarginRight   = _openGLViewMarginRight;

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
        
        [self.openGLView initOpenGLWithSharedContext:self.openGLContext];
        [self.openGLView setAutoresizingMask:NSViewNotSizable];
        [self.openGLView removeConstraints:self.openGLView.constraints];
        
        self.openGLViewMarginLeft = self.openGLView.frame.origin.x;
        self.openGLViewMarginRight = self.view.frame.size.width - NSMaxX(self.openGLView.frame);
        self.openGLViewMarginBottom = self.openGLView.frame.origin.y;
        self.openGLViewMarginTop = self.view.frame.size.height - NSMaxY(self.openGLView.frame);
        
        [self setOpenGLViewFameAccordingToAspectRatioInSuperview:self.view.frame];
        
        if([self.view isKindOfClass:[VSPreviewView class]]){
            ((VSPreviewView*) self.view).frameResizingDelegate = self;
        }
    }
}

-(void) setOpenGLViewFameAccordingToAspectRatioInSuperview:(NSRect) superViewsRect{
    
    NSRect openGLViewRect;

    openGLViewRect.size.width = superViewsRect.size.width - self.openGLViewMarginLeft - self.openGLViewMarginRight;
    openGLViewRect.size.height = superViewsRect.size.height - self.openGLViewMarginTop - self.openGLViewMarginBottom;
    
    float aspectRatio = [VSProjectSettings sharedProjectSettings].aspectRatio;
    
    float proportionalHeight = openGLViewRect.size.width / aspectRatio;
    
    if(proportionalHeight<openGLViewRect.size.height){
        openGLViewRect.size.height = proportionalHeight;
    }
    else{
        openGLViewRect.size.width = openGLViewRect.size.height * aspectRatio;
    }
    
    openGLViewRect.origin.x = (superViewsRect.size.width - openGLViewRect.size.width) / 2.0f;
    openGLViewRect.origin.y = superViewsRect.size.height - openGLViewRect.size.height - self.openGLViewMarginTop;
    
    [self.openGLView setFrameProportionally:openGLViewRect];
    
    [self.openGLView setNeedsLayout:YES];
    [self.openGLView setNeedsDisplay:YES];
}

#pragma mark - IBAction

- (IBAction)play:(NSButton *)sender {
    if([self delegateRespondsToSelector:@selector(play) ]){
        [self.openGLView startDisplayLink];
        [self.delegate play];
    }
}

- (IBAction)stop:(NSButton *)sender {
    if([self delegateRespondsToSelector:@selector(stop) ]){
        [self.openGLView stopDisplayLink];
        [self.delegate stop];
    }
}

#pragma mark - VSPlaybackControllerDelegate implementation

-(void) texture:(GLuint)theTexture isReadyForTimestamp:(double)theTimestamp{
    self.openGLView.texture = theTexture;
}

-(void) didStartScrubbingAtTimestamp:(double)aTimestamp{
    [self.openGLView startDisplayLink];
}

-(void) didStopScrubbingAtTimestamp:(double)aTimestamp{
    [self.openGLView stopDisplayLink];
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

#pragma mark - VSFrameResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetTo:(NSRect)newRect{
    [self setOpenGLViewFameAccordingToAspectRatioInSuperview:newRect];
}

@end
