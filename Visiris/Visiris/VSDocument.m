//
//  VSDocument.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 31.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDocument.h"

#import "VSMainWindowController.h"
#import "VSProjectItemController.h"
#import "VSTimeline.h"
#import "VSPostProcessor.h"
#import "VSPreProcessor.h"
#import "VSPlaybackController.h"
#import "VSProjectSettings.h"

#import "VSCoreServices.h"

@interface VSDocument()

@property (strong) VSMainWindowController *mainWindowController;
@property VSProjectItemController *projectItemController;


@end

@implementation VSDocument

@synthesize mainWindowController = _mainWindowController;
@synthesize projectItemController = _projectItemController;
@synthesize preProcessor = _preProcessor, postProcessor=_postProcessor;
@synthesize playbackController = _playbackController;
@synthesize timeline = _timeline;

- (id)init
{
    self = [super init];
    if (self) {
        self.projectItemController = [VSProjectItemController sharedManager];
        
        
        [self initVisiris];
    }
    return self;
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

}

-(void) makeWindowControllers{
    self.mainWindowController = [[VSMainWindowController alloc] init];
    [self addWindowController:self.mainWindowController];
    [self.mainWindowController setDocument:self];
}

/**
 * Does the base initialisation of the application.
 */
-(void) initVisiris{
    
    [[VSProjectSettings sharedProjectSettings] setFrameSize:NSMakeSize(800, 600)];
    
    //TODO: where to create the timeline?
    
    //** Creates a new timeline an sets its duratio to the DefaultDuration */
    self.timeline = [[VSTimeline alloc] initWithDuration:VSTimelineDefaultDuration];
    
    //** Adding 2 new VisualTracks to the timeline
    for(int i = 0; i<5; i++){
        [self.timeline addNewTrackNamed:[NSString stringWithFormat:@"track%ld",i] ofType:VISUAL_TRACK];
    }
    
    //** Adding 1 new Audrio-Track to the timeline */
    [self.timeline addNewTrackNamed:[NSString stringWithFormat:@"Audio Track"] ofType:AUDIO_TRACK];
    
    self.preProcessor = [[VSPreProcessor alloc] initWithTimeline:self.timeline];
    
    
    self.postProcessor = [[VSPostProcessor alloc] initWithPlaybackController:self.playbackController];
    
    self.preProcessor.renderCoreReceptionist.delegate = self.postProcessor;
    
    self.playbackController = [[VSPlaybackController alloc] initWithPreProcessor:self.preProcessor timeline:self.timeline];
    
    self.postProcessor = [[VSPostProcessor alloc] initWithPlaybackController:self.playbackController];
    
    self.preProcessor.renderCoreReceptionist.delegate = self.postProcessor;
    
    
    self.timeline.timelineObjectsDelegate = self.preProcessor;
    
}


+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

-(BOOL) readFromURL:(NSURL *)url ofType:(NSString *)type{
    DDLogError(@"%@",url);
    return YES;
}

-(BOOL) addFileToProject:(NSString*) fileName{
    return [self.projectItemController addNewProjectItemFromFile:fileName];
}

@end
