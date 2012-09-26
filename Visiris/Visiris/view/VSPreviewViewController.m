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
#import "VSFullScreenController.h"



@interface VSPreviewViewController ()

/** Top Margin of the openGLView to its superview */
@property NSInteger         openGLViewMarginTop;

/** Bottom Margin of the openGLView to its superview */
@property NSInteger         openGLViewMarginBottom;

/** Left Margin of the openGLView to its superview */
@property NSInteger         openGLViewMarginLeft;

/** Rigth Margin of the openGLView to its superview */
@property NSInteger         openGLViewMarginRight;

@property (assign) CVDisplayLinkRef         displayLink;

@property (strong) VSFullScreenController       *secondScreen;

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
@synthesize displayLink             = _displayLink;
@synthesize secondScreen            = _secondScreen;

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

/**
 * Inits the observerse of VSPreviewViewController
 */
-(void) initObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playKeyWasPressed:) name:VSPlayKeyWasPressed object:nil];
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
    //todo das geht besser
    [self.openGLView setOpenGLWithSharedContext:self.openGLContext];
    [self.openGLView setAutoresizingMask:NSViewNotSizable];
    
    self.secondScreen = [[VSFullScreenController alloc] initWithContext:self.openGLContext atScreen:1];
    
    [self setupDisplayLink];
}


#pragma  mark - VSViewController

-(void) awakeFromNib{ 
    if(self.view){
        
        [self initOpenGLView];
        
        [self initObservers];
        
        [self storeOpenGLViewsMargins];
        
        [self setOpenGLViewFameAccordingToAspectRatioInSuperview:self.view.frame];
        
        if([self.view isKindOfClass:[VSPreviewView class]]){
            ((VSPreviewView*) self.view).frameResizingDelegate = self;
        }
    }
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
}

#pragma mark - VSPlaybackControllerDelegate implementation

-(void) texture:(GLuint)theTexture isReadyForTimestamp:(double)theTimestamp{
    self.openGLView.texture = theTexture;
    [self.secondScreen updateWithTexture:theTexture];
    [self.openGLView drawView];
}

-(void) didStartScrubbingAtTimestamp:(double)aTimestamp{
    [self startDisplayLink];
}

-(void) didStopScrubbingAtTimestamp:(double)aTimestamp{
    [self stopDisplayLink];
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
    
    
    //resizes the NSRect according to the aspectRatio stored in VSProjectSettings
    float aspectRatio = [VSProjectSettings sharedProjectSettings].aspectRatio;
    
    float proportionalHeight = openGLViewRect.size.width / aspectRatio;
    
    if(proportionalHeight<openGLViewRect.size.height){
        openGLViewRect.size.height = proportionalHeight;
    }
    
    openGLViewRect.size.width = openGLViewRect.size.height * aspectRatio;
    
    
    openGLViewRect.origin.x = (superViewsRect.size.width - openGLViewRect.size.width) / 2.0f;
    openGLViewRect.origin.y = (NSMaxY(superViewsRect) - NSMaxY(openGLViewRect)) / 2.0f;
    
    [VSProjectSettings sharedProjectSettings].frameSize = openGLViewRect.size;
    [self.openGLView setFrameProportionally:NSIntegralRect(openGLViewRect)];
    
    
    
    [self.openGLView setNeedsLayout:YES];
    [self.openGLView setNeedsDisplay:YES];
}

/**
 * Tells the playbackController to start the playback and turns on the display link
 */
- (void)startPlayback {
    if(self.playbackController){
        [self startDisplayLink];
        [self.playbackController play];
    }
}

/**
 * Tells the playbackController to stop the playback and turns off the display link
 */
- (void)stopPlayback {
    if(self.playbackController){
        [self stopDisplayLink];
        [self.playbackController stop];
    }
}

/**
 * Called when the VSPlayKeyWasPressed notification was received.
 *
 * Stops the the playback if the playMode of the playbackController is VSPlaybackModePlaying and starts it otherwise
 *
 * @param theNotification NSNotification send from the notification
 */
-(void) playKeyWasPressed:(NSNotification*) theNotification{
    if(self.playbackController.playbackMode == VSPlaybackModePlaying){
        [self stopPlayback];
    }
    else {
        [self startPlayback];
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

- (void) startDisplayLink{
	if (_displayLink && !CVDisplayLinkIsRunning(_displayLink))
		CVDisplayLinkStart(_displayLink);
    // DDLogInfo(@"startDisplayLink");
}

- (void)stopDisplayLink{
	if (_displayLink && CVDisplayLinkIsRunning(_displayLink))
		CVDisplayLinkStop(_displayLink);
    //   DDLogInfo(@"stopDisplayLink");
}

- (double)refreshPeriod{
    return CVDisplayLinkGetActualOutputVideoRefreshPeriod(self.displayLink);
}

- (uint64_t)hostTime{
    CVTimeStamp stamp;
    CVDisplayLinkGetCurrentTime(self.displayLink,&stamp);
    return stamp.hostTime;
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime{
    @autoreleasepool {
        [self.playbackController renderFramesForCurrentTimestamp];
        return kCVReturnSuccess;
    }
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge VSPreviewViewController*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) setupDisplayLink{
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self.openGLView openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self.openGLView pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
}

@end
