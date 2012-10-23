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
#import "VSProjectItemRepresentationController.h"
#import "VSTimeline.h"
#import "VSTrack.h"
#import "VSTimelineObject.h"
#import "VSPostProcessor.h"
#import "VSPreProcessor.h"
#import "VSPlaybackController.h"
#import "VSProjectSettings.h"
#import "VSOutputController.h"
#import "VSDeviceManager.h"
#import "VSExternalInputManager.h"

#import "VSCoreServices.h"

@interface VSDocument()

@property (strong) VSMainWindowController *mainWindowController;



@end

@implementation VSDocument

#define kTimeline @"Timeline"

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.projectItemController = [[VSProjectItemController alloc] init];
        self.projectItemRepresentationController = [[VSProjectItemRepresentationController alloc]initForProjectItemController:self.projectItemController];
        
        self.externalInputManager = [VSExternalInputManager sharedExternalInputManager];
    }
    return self;
}


-(id) initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    if(self = [self init]){
        if([typeName isEqualToString:VSVisirsUTI]){
            //    [[VSProjectSettings sharedProjectSettings] setFrameSize:NSMakeSize(640, 480)];
            
            //TODO: where to create the timeline?
            
            //** Creates a new timeline an sets its duratio to the DefaultDuration */
            self.timeline = [[VSTimeline alloc] initWithDuration:VSTimelineDefaultDuration
                                        andProjectItemController:self.projectItemController];
            
            //** Adding 2 new VisualTracks to the timeline
            for(int i = 0; i<6; i++){
                [self.timeline addNewTrackNamed:[NSString stringWithFormat:@"%d",i] ofType:VISUAL_TRACK];
            }
            
            //** Adding 1 new Audrio-Track to the timeline */
            //    [self.timeline addNewTrackNamed:[NSString stringWithFormat:@"%d",i] ofType:AUDIO_TRACK];
            
            [self initVisiris];
        }
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
    
    
    self.preProcessor = [[VSPreProcessor alloc] initWithTimeline:self.timeline];
    
    
    self.outputController = [[VSOutputController alloc] initWithOpenGLContext:self.preProcessor.renderCoreReceptionist.openGLContext];
    
    
    
    
    self.postProcessor = [[VSPostProcessor alloc] initWithPlaybackController:self.playbackController];
    
    self.preProcessor.renderCoreReceptionist.delegate = self.postProcessor;
    
    self.playbackController = [[VSPlaybackController alloc] initWithPreProcessor:self.preProcessor
                                                             andOutputController:self.outputController
                                                                     forTimeline:self.timeline ofDocument:self];
    
    self.outputController.playbackController = self.playbackController;
    
    self.postProcessor = [[VSPostProcessor alloc] initWithPlaybackController:self.playbackController];
    
    self.preProcessor.renderCoreReceptionist.delegate = self.postProcessor;
    self.preProcessor.delegate = self.playbackController;
    
    self.timeline.timelineObjectsDelegate = self.preProcessor;
    
    
    self.deviceManager = [[VSDeviceManager alloc] init];
    self.deviceManager.deviceRegisitratingDelegate = self.externalInputManager;
    
}

#pragma mark - NSDocument

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if([typeName isEqualToString:VSVisirsUTI]){
        NSData *data;
        NSMutableDictionary *doc = [[NSMutableDictionary alloc] init];
        NSString *errorString;
        
        [doc setObject:[NSKeyedArchiver archivedDataWithRootObject:self.timeline]
                forKey:kTimeline];
        
        data = [NSPropertyListSerialization dataFromPropertyList:doc
                                                          format:NSPropertyListXMLFormat_v1_0
                                                errorDescription:&errorString];
        
        if (!data) {
            if (!outError) {
                NSLog(@"dataFromPropertyList failed with %@", errorString);
            }
            else {
                NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Visirs document couldn't be written", NSLocalizedDescriptionKey, (errorString ? errorString : @"An unknown error occured."), NSLocalizedFailureReasonErrorKey, nil];
                
                // In this simple example we know that no one's going to be paying attention to the domain and code that we use here.
                *outError = [NSError errorWithDomain:@"visirisErrorDomain" code:-1 userInfo:errorUserInfo];
            }
            
        }
        return data;
    } else {
        if (outError) *outError = [NSError errorWithDomain:@"visirisErrorDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unsupported data type: %@", typeName] forKey:NSLocalizedFailureReasonErrorKey]];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    
    BOOL result = NO;
    
    // we only recognize one data type.  It is a programming error to call this method with any other typeName
    assert([typeName isEqualToString:VSVisirsUTI]);
    
    NSString *errorString;
    NSDictionary *documentDictionary = [NSPropertyListSerialization propertyListFromData:data
                                                                        mutabilityOption:NSPropertyListImmutable
                                                                                  format:NULL
                                                                        errorDescription:&errorString];
    
    if (documentDictionary) {
        
        
        self.timeline = [NSKeyedUnarchiver unarchiveObjectWithData:[documentDictionary objectForKey:kTimeline]];
        
        if(self.timeline){
            self.projectItemController = [[VSProjectItemController alloc] init];
            self.projectItemRepresentationController = [[VSProjectItemRepresentationController alloc]initForProjectItemController:self.projectItemController];
            self.timeline.projectItemController = self.projectItemController;
            
            [self initVisiris];
        }
        
        result = YES;
    } else {
        if (!outError) {
            NSLog(@"propertyListFromData failed with %@", errorString);
        } else {
            NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"iSpend document couldn't be read", NSLocalizedDescriptionKey, (errorString ? errorString : @"An unknown error occured."), NSLocalizedFailureReasonErrorKey, nil];
            
            *outError = [NSError errorWithDomain:@"iSpendErrorDomain" code:-1 userInfo:errorUserInfo];
        }
        result = NO;
    }
    // we don't want any of the operations involved in loading the new document to mark it as dirty, nor should they be undo-able, so clear the undo stack
    [[self undoManager] removeAllActions];
    return result;
}

-(BOOL) readFromURL:(NSURL *)url ofType:(NSString *)type{
    DDLogError(@"%@",url);
    return NO;
}

#pragma mark - Methods

-(BOOL) addFileToProject:(NSString*) fileName{
    return [self.projectItemController addNewProjectItemFromFile:fileName];
}

@end
