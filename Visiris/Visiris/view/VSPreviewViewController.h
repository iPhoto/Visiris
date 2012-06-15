//
//  VSPreviewViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSCoreServices.h"
#import "VSPreviewOpenGLView.h"

@protocol VSPreviewViewControllerDelegate <NSObject>

-(void) play;

-(void) stop;

@end

@class VSPlaybackController;

#import "VSPlaybackController.h"

/**
 * Subclass of NSViewController responsible for the Previw at the top-right of the window
 */
@interface VSPreviewViewController : NSViewController<VSPlaybackControllerDelegate>

//for testing purpose only
@property (strong) VSPlaybackController *playBackController;

@property (strong) NSOpenGLContext *openGLContext;

@property id<VSPreviewViewControllerDelegate> delegate;

@property (weak) IBOutlet VSPreviewOpenGLView *openGLView;

#pragma mark - init

-(id) initWithDefaultNibForOpenGLContext:(NSOpenGLContext*) theOpenGLContext;
- (IBAction)play:(NSButton *)sender;
- (IBAction)stop:(NSButton *)sender;

@property (weak) IBOutlet NSView *openGLViewHolder;

@end
