//
//  VSSecondScreen.m
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import "VSFullScreenController.h"
#import "VSPreviewOpenGLView.h"

#import "VSFullScreenOpenGLView.h"

@interface VSFullScreenController()
@property (strong) VSFullScreenOpenGLView   *fullScreenView ;
@property (strong) NSWindow                 *fullScreenWindow;
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

- (id)initWithContext:(NSOpenGLContext *)context atScreen:(NSInteger)screenID{
    if (self = [super init]) {
        
        if (screenID >= [NSScreen screens].count) {
            NSLog(@"ERROR: Screen Initialisation not possible because screenID not available");
            return nil;
        }
                
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
        
        NSRect viewRect = NSMakeRect(0.0, 0.0, secondDisplayRect.size.width, secondDisplayRect.size.height);
        
        self.fullScreenView = [[VSFullScreenOpenGLView alloc] initWithFrame:viewRect];
        [self.fullScreenView setOpenGLWithSharedContext:context];
        [self.fullScreenWindow setContentView: self.fullScreenView];
        [self.fullScreenWindow makeKeyAndOrderFront:self];
    }
    return self;
}

- (void)updateWithTexture:(GLuint)texture{
    self.fullScreenView.texture = texture;
    [self.fullScreenView drawView];
}

@end
