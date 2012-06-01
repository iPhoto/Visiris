//
//  VSDocument.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 31.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSPreProcessor;
@class VSPostProcessor;
@class VSTimeline;
@class VSPlaybackController;

@interface VSDocument : NSDocument

/** VSPreProcessor is initialized by VSMainWindowController */
@property (strong) VSPreProcessor *preProcessor;

/** VSPostProcessor is initialized by VSMainWindowController */
@property (strong) VSPostProcessor *postProcessor;

/** VSPlaybackController is initialized by VSMainWindowController */
@property (strong) VSPlaybackController *playbackController;

/** VSTimeline is initialized by VSMainWindowController */
@property (strong) VSTimeline* timeline;


-(BOOL) addFileToProject:(NSString*) fileName;

@end
