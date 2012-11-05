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
@class VSExternalInputManager;
@class VSDeviceManager;
@class VSExternalInputManager;
@class VSOutputController;
@class VSProjectItemController;
@class VSProjectItemRepresentationController;
@class VSCoreReceptionist;



/**
 * Please add more here
 */
@interface VSDocument : NSDocument

/** VSPreProcessor is initialized by VSMainWindowController */
@property (strong) VSPreProcessor *preProcessor;

/** VSPostProcessor is initialized by VSMainWindowController */
@property (strong) VSPostProcessor *postProcessor;

/** VSPlaybackController is initialized by VSMainWindowController */
@property (strong) VSPlaybackController *playbackController;

/** VSTimeline is initialized by VSMainWindowController */
@property (strong) VSTimeline* timeline;

@property (strong) VSOutputController *outputController;

/** VSDeviceManager handles the devices and their representations */
@property (strong) VSDeviceManager *deviceManager;
 
@property (strong) VSExternalInputManager *externalInputManager;

@property (strong) VSCoreReceptionist *coreReceptionist;

@property (strong) VSProjectItemController *projectItemController;
@property (strong) VSProjectItemRepresentationController *projectItemRepresentationController;

-(BOOL) addFileToProject:(NSString*) fileName;

@end
