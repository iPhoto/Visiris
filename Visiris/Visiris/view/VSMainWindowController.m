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

#pragma mark - Init

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
    
    [self.window setAcceptsMouseMovedEvents:YES];
    
    //checks if the document is a visirs document
    if(self.document && [self.document isKindOfClass:[VSDocument class]]){
        /** inits the spltiview with their subviews */
        [self initSplitViews];
        
        [self initMainWindowAccordingToDocument];
    }
    
    [self.mainSplitView adjustSubviews];
    [self.topSplitView  adjustSubviews];
    
}

#pragma mark - NSWindow


#pragma mark - Methods

/**
 * Inits the controllers of the subviews in the main window with the information stored in VSMainWindowController's VSDocument.
 *
 * Sets the timeleline and connects the different parts of the playback and connection with the core
 */
-(void) initMainWindowAccordingToDocument{
    
    self.timelineViewController = [[VSTimelineViewController alloc] initWithDefaultNibAccordingForTimeline:((VSDocument*) self.document).timeline];
    
    [self loadView:timelineViewController.view intoSplitView:self.mainSplitView replacingViewAtPosition:1];
    
    
    self.previewViewController = [[VSPreviewViewController alloc] initWithDefaultNibForOpenGLContext:((VSDocument*) self.document).preProcessor.renderCoreReceptionist.openGLContext];
    
    [self loadView:self.previewViewController.view intoSplitView:self.topSplitView replacingViewAtPosition:2];
    
    self.previewViewController.playbackController = ((VSDocument*) self.document).playbackController;
    
    ((VSDocument*) self.document).playbackController.delegate = self.previewViewController;
}

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

#pragma mark- Private Methods


/**
 * Replaces given splitView'S subview at the given position with the given view.
 * @param view View to replace the subview at "position"
 * @param splitView NSSplitView the new View will be loaded into.
 * @param position Index of splitView's subview which will be replaced by given view
 */
-(void) loadView:(NSView*) view intoSplitView:(NSSplitView*) splitView replacingViewAtPosition:(NSInteger) position{
    
    NSRect frame = [[splitView.subviews objectAtIndex:position] frame];
    
    [splitView replaceSubview:[splitView.subviews objectAtIndex:position] with:view];
    [view  setFrame:frame];
    
    [view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [view setAutoresizesSubviews:YES];
    
    NSLog(@"loading view: %@ with frame: %@",view, NSStringFromRect(frame));
}

#pragma mark - NSSplitViewDelegate Implementation

-(void) splitViewWillResizeSubviews:(NSNotification *)notification{
    
    NSSplitView *splitView = (NSSplitView*)[notification object];
    if(splitView == self.mainSplitView){
        for(NSView* subview in splitView.subviews)
        {
            
//            if(subview == self.timelineViewController.view){
//                if(subview.frame.size.height > 100){
//                    [subview setFrameSize:NSMakeSize(subview.frame.size.width, 100)];
//                }
//            }
        }
    }
//    else if(splitView == self.topSplitView){
//        for(NSView *subView in splitView.subviews){
//            if(subView.frame.size.width < 50){
//                DDLogInfo(@"%@ is Collpased: %d", subView,               [splitView isSubviewCollapsed:subView]);
//                NSRect frame = subView.frame;
//                frame.size.width = 50;
//                [subView setFrame:frame];
//            }
//        }
//    }
}

-(CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    DDLogInfo(@"proposedMinimumPosition: %f for dividerIndex : %ld",proposedMinimumPosition,dividerIndex);
    if(splitView == self.topSplitView){
        switch (dividerIndex) {
            case 0:
                return proposedMinimumPosition + 100;
                break;
            case 1:
                return proposedMinimumPosition + 200;
                break;
        }
    }
    
    return proposedMinimumPosition;
}

-(CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
//    DDLogInfo(@"proposedMaximumPosition: %f for dividerIndex : %ld",proposedMaximumPosition,dividerIndex);
    if(splitView == self.topSplitView){
        switch (dividerIndex) {
            case 0:
                return proposedMaximumPosition - 300;
                break;
            case 1:
                return proposedMaximumPosition - 400;
                break;
        }
    }
    
    return proposedMaximumPosition;
}

@end
