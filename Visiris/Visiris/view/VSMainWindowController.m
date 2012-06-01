//
//  VSMainWindowController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSMainWindowController.h"

#import "VSBrowserViewController.h"
#import "VSTimelineViewController.h"
#import "VSTimeline.h"
#import "VSPreProcessor.h"
#import "VSPostProcessor.h"
#import "VSPlaybackController.h"
#import "VSPropertiesViewController.h"
#import "VSPreviewViewController.h"
#import "VisirisCore/VSCoreReceptionist.h"
#import "VSDocument.h"

#import "VSCoreServices.h"

@interface VSMainWindowController ()
/** Responsible for the browser view which is shown at the top left of the window. */
@property (strong) VSBrowserViewController *browserViewController;

/** Responsible for the timelineView which is shown at the bottom of the window. */
@property (strong) VSTimelineViewController *timelineViewController;

/** Responsible for the browser view which is shown at the top center of the window. */
@property (strong) VSPropertiesViewController *propertiesViewController;





@end

@implementation VSMainWindowController
@synthesize topSplitView = _topSplitView;
@synthesize mainSplitView = _mainSplitView;
@synthesize propertiesViewController = _propertiesViewController;
@synthesize previewViewController = _previewViewController;
@synthesize browserViewController,timelineViewController;

static NSString* defaultNib = @"MainWindow";

-(id) init{
    if(self = [self initWithWindowNibName:defaultNib]){
        
    }
    
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if([self.document isKindOfClass:[VSDocument class]]){
        [self initTimelineViewWithTimeline:((VSDocument*) self.document).timeline];
        [self initPreviewViewWithOpenGLContext:((VSDocument*) self.document).preProcessor.renderCoreReceptionist.openGLContext];
        
        self.previewViewController.delegate = ((VSDocument*) self.document).playbackController;
        ((VSDocument*) self.document).playbackController.delegate = self.previewViewController;
    }
    /** inits the spltiview with their subviews */
    [self initSplitViews];
}

#pragma mark - Methods

-(void) initTimelineViewWithTimeline:(id)timeline{
    self.timelineViewController = [[VSTimelineViewController alloc] initWithDefaultNibAccordingForTimeline:timeline];
    [self loadView:timelineViewController.view intoSplitView:self.mainSplitView replacingViewAtPosition:1];
}

-(void) initPreviewViewWithOpenGLContext:(NSOpenGLContext *)openGLContext{
    //Addin the VSPreviewView to the top right
    self.previewViewController = [[VSPreviewViewController alloc] initWithDefaultNibForOpenGLContext:openGLContext];                                        
    
    [self loadView:self.previewViewController.view intoSplitView:self.topSplitView replacingViewAtPosition:2];
    

}

#pragma mark- Private Methods
/**
 * Inits the splitViews of the window with different Views according to their positions.
 */
-(void) initSplitViews{
    
    self.browserViewController = [[VSBrowserViewController alloc] initWithDefaultNib];
    [self loadView:browserViewController.view intoSplitView:self.topSplitView replacingViewAtPosition:0];
    
    //Adding the VSPropertiesView to the top center
    self.propertiesViewController = [[VSPropertiesViewController alloc] initWithDefaultNib];
    [self loadView:self.propertiesViewController.view intoSplitView:self.topSplitView replacingViewAtPosition:1];
    
}

/**
 * Replaces given splitView'S subview at the given position with the given view. 
 * @param view View to replace the subview at "position"
 * @param splitView NSSplitView the new View will be loaded into.
 * @param position Index of splitView's subview which will be replaced by given view
 */
-(void) loadView:(NSView*) view intoSplitView:(NSSplitView*) splitView replacingViewAtPosition:(NSInteger) position{
    NSRect frame = [[splitView.subviews objectAtIndex:position] bounds];
    
    [splitView replaceSubview:[splitView.subviews objectAtIndex:position] with:view];
    [view  setFrame:frame];
    
    [view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [view setAutoresizesSubviews:YES];
}

#pragma mark- Private Methods


#pragma mark - NSSplitViewDelegate implementation

-(void) splitViewDidResizeSubviews:(NSNotification *)notification{
    if (notification.object == self.topSplitView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSTopSplitViewDidResizeSubviews object:notification.object];
    }
    else if (notification.object == self.mainSplitView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSMainSplitViewDidResizeSubviews object:notification.object];
    }
}

@end
