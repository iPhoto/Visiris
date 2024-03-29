//
//  VSOutputController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 26.09.12.
//
//

#import "VSOutputController.h"
#import "VSPlaybackController.h"
#import "VSProjectSettings.h"

@interface VSOutputController()

@property (assign) CVDisplayLinkRef     displayLink;
@property (strong) NSMutableArray       *registratedOutputs;
@property (strong) NSOpenGLContext      *openGLContext;
@property (assign) BOOL                 isFullScreen;
@property (assign) NSSize               renderSize;
@property (assign) GLuint               lastTexture;
@property (assign) double               lastTimestamp;
@property (strong) NSMutableArray       *outputsToBeRemoved;

@end


@implementation VSOutputController
@synthesize fullScreenSize  = _fullScreenSize;
@synthesize previewSize     = _previewSize;

#pragma mark - Init

-(id) initWithOpenGLContext:(NSOpenGLContext*) openGLContext{
    if(self = [super init]){
        [self setupDisplayLink];
        self.registratedOutputs = [[NSMutableArray alloc] init];
        self.isFullScreen       = NO;
        self.renderSize         = [[VSProjectSettings sharedProjectSettings] frameSize];
        self.lastTexture        = 0;
        self.lastTimestamp      = 0.0;
        self.openGLContext = openGLContext;
        NSOpenGLPixelFormatAttribute attribs[] =
        {
            kCGLPFAAccelerated,
            kCGLPFANoRecovery,
            kCGLPFADoubleBuffer,
            kCGLPFAColorSize, 24,
            kCGLPFADepthSize, 16,
            0
        };
        
        self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    }
    
    return self;
}

#pragma mark - Methods

-(NSOpenGLContext*) registerAsOutput:(id<VSOpenGLOutputDelegate>) output{
    
    BOOL valid = false;
    
    if(output){
        if([output conformsToProtocol:@protocol(VSOpenGLOutputDelegate)]){
            if([output respondsToSelector:@selector(showTexture:)]){
                valid = YES;
            }
        }
    }
    
    if(valid)
        [self.registratedOutputs addObject:output];
    
    return self.openGLContext;
}

//TODO: not the best way to check if fullscreen is on
-(void) unregisterOutput:(id<VSOpenGLOutputDelegate>)output{
    
    if(!CVDisplayLinkIsRunning(_displayLink)){
        [self removeOutput:output];
    }
    else{
        if(!self.outputsToBeRemoved){
            self.outputsToBeRemoved = [[NSMutableArray alloc] init];
        }
    
    [self.outputsToBeRemoved addObject:output];
}
}

-(void) removeOutput:(id<VSOpenGLOutputDelegate>) output{
    [self.registratedOutputs removeObject:output];
    self.isFullScreen = NO;
    [self calcRenderSize];
}

-(void) startPlayback{
    [self startDisplayLink];
}

-(void) stopPlayback{
    [self stopDisplayLink];
}

- (void) startDisplayLink{
	if (_displayLink && !CVDisplayLinkIsRunning(_displayLink))
		CVDisplayLinkStart(_displayLink);
}

- (void)stopDisplayLink{
	if (_displayLink && CVDisplayLinkIsRunning(_displayLink))
		CVDisplayLinkStop(_displayLink);
}

-(void) didStartScrubbingAtTimestamp:(double)aTimestamp{
    [self startDisplayLink];
}

-(void) didStopScrubbingAtTimestamp:(double)aTimestamp{
    [self stopDisplayLink];
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime{
    @autoreleasepool {
        [self.playbackController renderFramesForCurrentTimestamp:self.renderSize];
        return kCVReturnSuccess;
    }
}

-(void) texture:(GLuint) theTexture isReadyForTimestamp:(double) theTimestamp{
    self.lastTexture = theTexture;
    self.lastTimestamp = theTimestamp;
    
    for(id<VSOpenGLOutputDelegate> openGlOutput in self.registratedOutputs){
        [openGlOutput showTexture:theTexture];
    }
    
    if(self.outputsToBeRemoved){
        for(id<VSOpenGLOutputDelegate> output in self.outputsToBeRemoved){
            [self removeOutput:output];
        }

        [self.outputsToBeRemoved removeAllObjects];
        self.outputsToBeRemoved = nil;
    }
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge VSOutputController*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) setupDisplayLink{

	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    
	// Set the display link for the current renderer
	CGLContextObj cglContext = [self.openGLContext CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [self.pixelFormat CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
}

#pragma mark - Properties

- (double)refreshPeriod{
    return CVDisplayLinkGetActualOutputVideoRefreshPeriod(self.displayLink);
}

- (void)setFullScreenSize:(NSSize)fullScreenSize{
    _fullScreenSize = fullScreenSize;
    self.isFullScreen = YES;
    [self calcRenderSize];
    //    [self texture:self.lastTexture isReadyForTimestamp:self.lastTimestamp];
}

- (void)setPreviewSize:(NSSize)previewSize{
    _previewSize = previewSize;
    [self calcRenderSize];
}

- (void)calcRenderSize{
    if (self.isFullScreen)
        self.renderSize = self.fullScreenSize;
    else
        self.renderSize = self.previewSize;
    
    if (self.renderSize.width > [[VSProjectSettings sharedProjectSettings] frameSize].width) {
        self.renderSize = [[VSProjectSettings sharedProjectSettings] frameSize];
    }
    [self.playbackController updateCurrentFrame];
}

@end
