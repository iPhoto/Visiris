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
#import "VSOutputController.h"

#import "VSCoreServices.h"
#import "VSFullScreenController.h"



@interface VSPreviewViewController ()

/** Top Margin of the openGLView to its superview */
@property (assign) NSInteger         openGLViewMarginTop;

/** Bottom Margin of the openGLView to its superview */
@property (assign) NSInteger         openGLViewMarginBottom;

/** Left Margin of the openGLView to its superview */
@property (assign) NSInteger         openGLViewMarginLeft;

/** Rigth Margin of the openGLView to its superview */
@property (assign) NSInteger         openGLViewMarginRight;

@property (weak) NSOpenGLContext *openGLContext;

@property (weak) VSOutputController *outputController;


@end


@implementation VSPreviewViewController

@synthesize openGLViewHolder        = _openGLViewHolder;
@synthesize openGLView              = _openGLView;
@synthesize openGLContext           = _openGLContext;
@synthesize openGLViewMarginTop     = _openGLViewMarginTop;
@synthesize openGLViewMarginBottom  = _openGLViewMarginBottom;
@synthesize openGLViewMarginLeft    = _openGLViewMarginLeft;
@synthesize openGLViewMarginRight   = _openGLViewMarginRight;
@synthesize playbackController      = _playbackController;
@synthesize fullScreenController            = _secondScreen;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSPreviewView";

#pragma mark - Init


-(id) initWithDefaultNibAndOutputController:(VSOutputController*) outputController{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.outputController = outputController;
        self.openGLContext = [self.outputController registerAsOutput:self];
        self.fullScreenController = [[VSFullScreenController alloc] initWithOutputController:self.outputController];
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



/**
 * Stores the margin of the openGLView as set in the InterfaceBuilder. Necessary for resizing the view proportionally afterwards
 */
- (void)storeOpenGLViewsMargins {
    self.openGLViewMarginLeft = self.openGLView.frame.origin.x;
    self.openGLViewMarginRight = self.view.frame.size.width - NSMaxX(self.openGLView.frame);
    self.openGLViewMarginBottom = self.openGLView.frame.origin.y;
    self.openGLViewMarginTop = self.view.frame.size.height - NSMaxY(self.openGLView.frame);
}

/**
 * Inits the openGLView and sets its autoresizing behaviour
 */
- (void)initOpenGLView{
    [self.openGLView setOpenGLWithSharedContext:self.openGLContext andPixelFrom:self.outputController.pixelFormat];
    [self.openGLView setAutoresizingMask:NSViewNotSizable];
}


#pragma  mark - VSViewController

-(void) awakeFromNib{ 
    if(self.view){
        
        [self initOpenGLView];
        
        [self storeOpenGLViewsMargins];
        
        [self setOpenGLViewFameAccordingToAspectRatioInSuperview:self.view.frame];
        
        if([self.view isKindOfClass:[VSPreviewView class]]){
            ((VSPreviewView*) self.view).frameResizingDelegate = self;
        }
        
        [self.frameRateSlider setFloatValue:[VSProjectSettings sharedProjectSettings].frameRate];
        [self.frameRateTextField setFloatValue:[VSProjectSettings sharedProjectSettings].frameRate];
    }
}

#pragma mark - VSOpenGLOutputDelegate

-(void) showTexture:(GLuint)texture{
    self.openGLView.texture = texture;
    [self.openGLView drawView];
}

#pragma mark - IBAction

- (IBAction)play:(NSButton *)sender {
    [self startPlayback];
}

- (IBAction)stop:(NSButton *)sender {
    [self stopPlayback];
}

- (IBAction)frameRateSliderHasChanged:(NSSlider *)sender {
    [VSProjectSettings sharedProjectSettings].frameRate = [sender integerValue];
    [self.frameRateTextField setFloatValue:[VSProjectSettings sharedProjectSettings].frameRate];
}


#pragma mark - VSFrameResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    [self setOpenGLViewFameAccordingToAspectRatioInSuperview:newRect];
}

-(void) viewDidEndLiveResizing:(NSView *)view{
    [self.playbackController updateCurrentFrame];
}

#pragma mark - Private Methods

/**
 * Computes a NSRect openGLView according to the aspectRatio stored in VSProjectSettings. Ensures that the openGLView is resized proportionally and positoned according to its margin-values in its superview
 *
 * @param superViewsRect Frame of the openGLView's super view
 */
-(void) setOpenGLViewFameAccordingToAspectRatioInSuperview:(NSRect) superViewsRect{
    
    NSRect openGLViewRect;
    
    //creates a nsrect according to the set margins
    openGLViewRect.size.width = superViewsRect.size.width - self.openGLViewMarginLeft - self.openGLViewMarginRight;
    openGLViewRect.size.height = superViewsRect.size.height - self.openGLViewMarginTop - self.openGLViewMarginBottom;
    

    openGLViewRect = [VSFrameUtils maxProportionalRectinRect:openGLViewRect inSuperView:superViewsRect];
    self.outputController.previewSize = openGLViewRect.size;
    
    [self.openGLView setFrameProportionally:NSIntegralRect(openGLViewRect)];
    
    [self.openGLView setNeedsLayout:YES];
    [self.openGLView setNeedsDisplay:YES];
}

/**
 * Tells the playbackController to start the playback and turns on the display link
 */
- (void)startPlayback {
    if(self.playbackController){
        [self.playbackController play];
    }
}

/**
 * Tells the playbackController to stop the playback and turns off the display link
 */
- (void)stopPlayback {
    if(self.playbackController){
        [self.playbackController stop];
    }
}



#pragma mark - Properties

-(void) setPlaybackController:(VSPlaybackController *)playBackController{
    
    //self.openGLView.playBackcontroller = playBackController;
    
    _playbackController = playBackController;
}

-(VSPlaybackController*) playbackController{
    return _playbackController;
}


- (IBAction)toggleFullScreen:(id)sender {

    
    NSInteger screenID  = [VSFullScreenController numberOfScreensAvailable]-1;
    
    if([VSFullScreenController numberOfScreensAvailable] > 1 && screenID == [VSFullScreenController mainScreen]){
        screenID  = [VSFullScreenController numberOfScreensAvailable]-2;
    }

    [self.fullScreenController toggleFullScreenForScreen:screenID];
}
@end
