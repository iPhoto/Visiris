//
//  VSSecondScreen.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSFullScreenController.h"

#import "VSPreviewOpenGLView.h"
#import "VSOutputController.h"
#import "VSProjectSettings.h"
#import "VSOutputController.h"
#import "VSCoreServices.h"
#import "VSFullScreenOpenGLView.h"

@interface VSFullScreenController()
@property (strong) VSFullScreenOpenGLView   *fullScreenView ;
@property (strong) NSView *holder;
@property (strong) NSWindow                 *fullScreenWindow;
@property (weak) NSOpenGLContext            *openGLContext;
@property BOOL visible;

@end


@implementation VSFullScreenController
@synthesize fullScreenView =    _fullScreenView;
@synthesize fullScreenWindow =  _fullScreenWindow;

+ (NSInteger)numberOfScreensAvailable{
    return [NSScreen screens].count;
}

+ (NSInteger)mainScreen{
    return [[NSScreen screens] indexOfObject:[NSScreen mainScreen]];
}

- (id)init{
    if (self = [super init]) {
        
        self.visible = false;
    }
    return self;
}

#pragma mark - VSOpenGLOutputDelegate Implementation

-(void) showTexture:(GLuint)texture{
    self.fullScreenView.texture = texture;
    [self.fullScreenView drawView];
}

-(void) showFullscreenOnScreen:(NSUInteger) screenID{
    if (screenID < [NSScreen screens].count) {
        
        self.openGLContext = [[VSOutputController sharedOutputController] registerAsOutput:self];
        
        NSScreen *screen = [[NSScreen screens] objectAtIndex:screenID];
        
        NSRect secondDisplayRect = [screen frame];
        
        self.fullScreenWindow = [[NSWindow alloc] initWithContentRect:secondDisplayRect
                                                            styleMask:NSBorderlessWindowMask
                                                              backing:NSBackingStoreBuffered
                                                                defer:YES];
        
        
        
        [self.fullScreenWindow setFrame:secondDisplayRect display:YES];
        [self.fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
        [self.fullScreenWindow setOpaque:NO];
    
        [self.fullScreenWindow setHidesOnDeactivate:NO];
        
        NSRect openglViewRect = NSMakeRect(0, 0, secondDisplayRect.size.width, secondDisplayRect.size.height);
        self.holder = [[NSView alloc] initWithFrame:openglViewRect];
        self.fullScreenView = [[VSFullScreenOpenGLView alloc] initWithFrame:openglViewRect];
        [self.fullScreenView setOpenGLWithSharedContext:self.openGLContext];
        [self.fullScreenWindow setContentView: self.holder];
        [self.fullScreenWindow makeKeyAndOrderFront:self];
        
        
        [self.holder addSubview:self.fullScreenView];
        
                
        openglViewRect = [VSFrameUtils maxProportionalRectinRect:openglViewRect inSuperView:secondDisplayRect];
      
        
        [self.fullScreenView setFrame:openglViewRect];

        [VSOutputController sharedOutputController].fullScreenSize = openglViewRect.size;
    }
}

-(void) hideFullscreen{
    [[VSOutputController sharedOutputController] unregisterOutput:self];
    
    [self.fullScreenWindow orderOut:self.fullScreenWindow];
    [self.fullScreenWindow setReleasedWhenClosed:YES];
//    [self.fullScreenWindow close];
}

-(void) toggleFullScreenForScreen:(NSUInteger) screenID{    
    if(self.visible){
        [self hideFullscreen];
    }
    else{
        [self showFullscreenOnScreen:screenID];
    }
    
    self.visible = !self.visible;
    [[VSOutputController sharedOutputController] toggleFullScreen];
}


@end
