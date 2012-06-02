//
//  VSPreviewViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VSCoreServices.h"

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

@property (strong) NSOpenGLContext *openGLContext;

@property id<VSPreviewViewControllerDelegate> delegate;

#pragma mark - init

-(id) initWithDefaultNibForOpenGLContext:(NSOpenGLContext*) theOpenGLContext;
- (IBAction)play:(NSButton *)sender;
- (IBAction)stop:(NSButton *)sender;

@property (weak) IBOutlet NSView *openGLViewHolder;

@end
