//
//  VSPreviewViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSPlaybackController;

@interface VSPreviewViewController : NSViewController

@property (strong) NSOpenGLContext *openGLContext;

@property VSPlaybackController *playbackController;

#pragma mark - init
-(id) initWithDefaultNibForOpenGLContext:(NSOpenGLContext*) theOpenGLContext;
- (IBAction)play:(NSButton *)sender;
- (IBAction)stop:(NSButton *)sender;
@property (weak) IBOutlet NSView *openGLViewHolder;

@end
