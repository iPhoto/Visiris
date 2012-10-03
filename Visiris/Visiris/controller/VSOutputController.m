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

@end


@implementation VSOutputController
@synthesize fullScreenSize  = _fullScreenSize;
@synthesize previewSize     = _previewSize;

static VSOutputController* sharedOutputController = nil;


#pragma mark- Functions

+(VSOutputController*)sharedOutputController{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedOutputController = [[VSOutputController alloc] init];
        
    });
    
    return sharedOutputController;
}


#pragma mark - Init

-(id) init{
    if(self = [super init]){
        [self setupDisplayLink];
        self.registratedOutputs = [[NSMutableArray alloc] init];
        self.isFullScreen       = NO;
        self.renderSize         = [[VSProjectSettings sharedProjectSettings] frameSize];
        self.lastTexture        = 0;
        self.lastTimestamp      = 0.0;
    }
    
    return self;
}

-(void) connectWithOpenGLContext:(NSOpenGLContext*) openGLContext{
    self.openGLContext = openGLContext;
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

-(void) unregisterOutput:(id<VSOpenGLOutputDelegate>)output{
    [self.registratedOutputs removeObject:output];
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
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge VSOutputController*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) setupDisplayLink{
    
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

- (void)toggleFullScreen{
    self.isFullScreen = !self.isFullScreen;    
    [self texture:self.lastTexture isReadyForTimestamp:self.lastTimestamp];
    [self calcRenderSize];
}

- (void)setFullScreenSize:(NSSize)fullScreenSize{
    _fullScreenSize = fullScreenSize;
    [self calcRenderSize];
}

- (void)setPreviewSize:(NSSize)previewSize{
    _previewSize = previewSize;
    [self renderSize];
}

- (void)calcRenderSize{
    if (self.isFullScreen)
        self.renderSize = self.fullScreenSize;
    else
        self.renderSize = self.previewSize;
    
    if (self.renderSize.width > [[VSProjectSettings sharedProjectSettings] frameSize].width) {
        self.renderSize = [[VSProjectSettings sharedProjectSettings] frameSize];
    }
}

@end
