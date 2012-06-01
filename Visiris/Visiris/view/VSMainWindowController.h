//
//  VSMainWindowController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTimeline;
@class VSPreviewViewController;

/**
 * Window Controller of the main window in the application
 *
 * Instantiates the Application when starting.
 */
@interface VSMainWindowController : NSWindowController<NSSplitViewDelegate>

/** Responsible for the preview view which is shown at the top right of the window. */
@property (strong) VSPreviewViewController *previewViewController;

/** VSSplitView at top of the window. Holds the Browser, the PropertiesView and the Preview View */
@property (weak) IBOutlet NSSplitView *topSplitView;

/** MainSplitview of Window. At top the topSplitView is placed at the bottom the timeline view. */
@property (weak) IBOutlet NSSplitView *mainSplitView;

@end
