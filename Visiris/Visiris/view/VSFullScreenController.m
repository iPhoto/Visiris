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
#import "VSFullScreenHolderView.h"
#import "VSCoreServices.h"
#import "VSFullScreenWindow.h"

#import "VSFullScreenOpenGLView.h"

@interface VSFullScreenController()
@property (strong) VSFullScreenOpenGLView *fullScreenView ;
@property (strong) VSFullScreenHolderView *holder;
@property (strong) VSFullScreenWindow *fullScreenWindow;
@property (weak) NSOpenGLContext *openGLContext;
@property (assign) BOOL visible;
@property (weak) VSOutputController *outputController;

@end


@implementation VSFullScreenController


+ (NSInteger)numberOfScreensAvailable{
    return [NSScreen screens].count;
}

+ (NSInteger)mainScreen{
    return [[NSScreen screens] indexOfObject:[NSScreen mainScreen]];
}

- (id)initWithOutputController:(VSOutputController *)outputController{
    if (self = [super init]) {
        self.outputController = outputController;
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
        
        self.openGLContext = [self.outputController registerAsOutput:self];
        
        NSScreen *screen = [[NSScreen screens] objectAtIndex:screenID];
        
        NSRect secondDisplayRect = [screen frame];
        
        self.fullScreenWindow = [[VSFullScreenWindow alloc] initWithContentRect:secondDisplayRect
                                                            styleMask:NSBorderlessWindowMask
                                                              backing:NSBackingStoreBuffered
                                                                defer:YES];
        
        
        
        [self.fullScreenWindow setFrame:secondDisplayRect display:YES];
        [self.fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
        [self.fullScreenWindow setOpaque:NO];
    
        [self.fullScreenWindow setHidesOnDeactivate:NO];
        
        NSRect openglViewRect = NSMakeRect(0, 0, secondDisplayRect.size.width, secondDisplayRect.size.height);
        self.holder = [[VSFullScreenHolderView alloc] initWithFrame:openglViewRect];
        self.holder.keyDownDelegate = self;
        self.fullScreenView = [[VSFullScreenOpenGLView alloc] initWithFrame:openglViewRect];
        [self.fullScreenView setOpenGLWithSharedContext:self.openGLContext andPixelFrom:self.outputController.pixelFormat];
        [self.fullScreenWindow setContentView: self.holder];
        [self.fullScreenWindow makeKeyAndOrderFront:self];
        
        
        [self.holder addSubview:self.fullScreenView];
        
                
        openglViewRect = [VSFrameUtils maxProportionalRectinRect:openglViewRect inSuperView:secondDisplayRect];
      
        
        [self.fullScreenView setFrame:openglViewRect];

        self.outputController.fullScreenSize = openglViewRect.size;
        
        self.visible = YES;
    }
}

-(void) hideFullscreen{
    [self.outputController unregisterOutput:self];
    
    [self.fullScreenWindow orderOut:self.fullScreenWindow];
    [self.fullScreenWindow setReleasedWhenClosed:YES];
    
    self.visible = NO;
}

-(void) toggleFullScreenForScreen:(NSInteger) screenID{    
    if(self.visible){
        [self hideFullscreen];
    }
    else{
        [self showFullscreenOnScreen:screenID];
    }
}


#pragma mark - VSViewKeyDownDelegate implementation

-(void) view:(NSView *)view didReceiveKeyDownEvent:(NSEvent *)theEvent{
    if(theEvent){
        unichar keyCode = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
        
        switch (keyCode) {
            case 32:
                [[NSNotificationCenter defaultCenter] postNotificationName:VSPlayKeyWasPressed object:nil];
                break;
            default:
                [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
                break;
        }
    }
}

-(void) cancelOperation:(id)sender{
    [self hideFullscreen];
}

@end
