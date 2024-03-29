//
//  VSTimelineViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSMainTimelineViewController.h"

#import "VSMainTimelineTrackViewController.h"
#import "VSTimeline.h"
#import "VSPlayHead.h"
#import "VSMainTimelineView.h"
#import "VSTimelineObjectProxy.h"
#import "VSTimelineRulerView.h"
#import "VSTimelineObject.h"
#import "VSTrackLabel.h"
#import "VSMainTimelineScrollViewDocumentView.h"
#import "VSProjectItemRepresentation.h"
#import "VSProjectItemController.h"
#import "VSProjectItemRepresentationController.h"
#import "VSDocumentController.h"
#import "VSDeviceManager.h"

#import "VSCoreServices.h"

@interface VSMainTimelineViewController ()

#define VS_PLAYHEAD_MINIMAL_PIXEL_DIFFERENCE 1

/** If an timelineObject is dragged to a different track the difference between the source track and the moveto-track is stored in trackOffset */
@property int trackOffset;

/** Indicates if autoscrolling is active. Is set to YES when a timelineObjectView is started to be dragged around and set to NO when the dragginOperation is done.*/
@property bool autoscrolling;

///** Timer for autostrolling */
//@property (strong) NSTimer *autoScrollingTimer;

/** Virtual mousePosition which is changed while autoscrolling is active */
@property (assign) NSPoint autoscrollMouseLocation;

/** Instance of VSProjectItemController */
@property (weak) VSProjectItemController *projectItemController;

/** Instance of VSProjectItemRepresentationController */
@property (weak) VSProjectItemRepresentationController *projectItemRepresentationController;

@property (strong) NSMutableDictionary *temporaryCreatedProjectItems;

@end

// Default width of the track labels
#define TRACK_LABEL_WIDTH 30

//minimum size a timeline object has to have when resizing
#define MINIMUM_TIMELINE_OBJECT_PIXEL_WIDTH 10

@implementation VSMainTimelineViewController

// Name of the nib that will be loaded when initWithDefaultNib is called
static NSString* defaultNib = @"VSMainTimelineView";

#pragma mark- Init

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObservers];
    
    [self.trackViewControllers removeAllObjects];
    self.trackViewControllers = nil;
}

-(void) removeObservers{
    [self.timeline removeObserver:self forKeyPath:@"duration"];
    [self.timeline.playHead removeObserver:self forKeyPath:@"currentTimePosition"];
    
    self.timeline = nil;
}

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.trackViewControllers = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

-(id) initWithDefaultNibAccordingForTimeline:(VSTimeline*)timeline projectItemController:(VSProjectItemController*) projectItemController projectionItemRepresentationController:(VSProjectItemRepresentationController *)projectItemRepresentationController andDeviceManager:(VSDeviceManager *)deviceManager{
    if(self = [self initWithDefaultNib]){
        self.timeline = timeline;
        self.projectItemController = projectItemController;
        self.projectItemRepresentationController = projectItemRepresentationController;
        self.deviceManager = deviceManager;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

-(void) awakeFromNib{
    
    if([self.view isKindOfClass:[VSMainTimelineView class]]){
        ((VSMainTimelineView*) self.view).mouseMoveDelegate = self;
    }
    
    self.temporaryCreatedProjectItems = [[NSMutableDictionary alloc] init];
    
    [super awakeFromNib];
    
    [self initTracks];
    
    [self computePixelTimeRatio];
    
    [self initObservers];
}

/**
 * Registratres the class for observing
 */
-(void) initObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineObjectPropertIesDidTurnInactive:)
                                                 name:VSTimelineObjectPropertiesDidTurnInactive
                                               object:nil];
    
    [self.timeline addObserver:self
                    forKeyPath:@"duration"
                       options:0
                       context:nil];
    
    [self.timeline.playHead addObserver:self
                             forKeyPath:@"currentTimePosition"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
}


/**
 * Creates a NSTrackView for every track the timeline holds
 */
-(void) initTracks{
    for(VSTrack* track in self.timeline.tracks){
        [self createTrack:track];
    }
}

#pragma mark - NSViewController


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    //updates the length of the tracks and their timeline objects when the duration of the timeline has been changed
    if([keyPath isEqualToString:@"duration"]){
        
        //updates the frame of the scrollViews trackHolderView
        
        
        self.scrollView.trackHolderWidth = [super pixelForTimestamp:[[object valueForKey:keyPath] doubleValue]];
        
        //updates the pixelItemRatio
        [self computePixelTimeRatio];
        
        
    }
    
    //moves the playheadMarker if the currentPosition of the timelines Playhead has been changed
    else if([keyPath isEqualToString:@"currentTimePosition"]){
        float newPlayHeadPosition = [super pixelForTimestamp:self.timeline.playHead.currentTimePosition];
        
        //The playHead Marker position is changed only if the difference of the new to the current playHead Marker position is bigger than VS_PLAYHEAD_MINIMAL_PIXEL_DIFFERENCE
        if(abs([self currentPlayheadMarkerLocation] - newPlayHeadPosition) >= VS_PLAYHEAD_MINIMAL_PIXEL_DIFFERENCE){
            [self setPlayheadMarkerLocation];
        }
    }
}

#pragma mark - NSResponder

-(void) moveRight:(id)sender{
    [self letPlayheadJumpOverTheDefaultDistanceForward:YES];
}

-(void)moveLeft:(id)sender{
    [self letPlayheadJumpOverTheDefaultDistanceForward:NO];
}

-(void) moveWordRight:(id) sender{
    [self moveToNextCutAndSearchForward:YES];
}

-(void) moveWordLeft:(id)sender{
    [self moveToNextCutAndSearchForward:NO];
}

-(void) deleteForward:(id)sender{
    [self removeSelectedTimelineObjects];
}

-(void)deleteBackward:(id)sender{
    [self removeSelectedTimelineObjects];
}

-(void) deleteToBeginningOfLine:(id)sender{
    [self removeSelectedTimelineObjects];
}

#pragma mark- VSViewResizingDelegate implementation

-(void) frameOfView:(NSView *)view wasSetFrom:(NSRect)oldRect to:(NSRect)newRect{
    
    if(oldRect.size.width != newRect.size.width){
        
        NSRect newDocumentFrame = [self.scrollView.trackHolderView frame];
        
        //updates the width according to how the width of the view has been resized
        newDocumentFrame.size.width += newRect.size.width - oldRect.size.width;
        [self.scrollView.trackHolderView setFrame:(newDocumentFrame)];
        [self computePixelTimeRatio];
    }
}


#pragma mark- VSTrackViewControlerDelegate implementation


#pragma mark Adding TimelineObjects

-(void) trackViewController:(VSMainTimelineTrackViewController *)trackViewController addTimelineObjectsBasedOnProjectItemRepresentation:(NSArray *)projectItemRepresentations atPositions:(NSArray *)positionArray withWidths:(NSArray *)widthArray{
    
    if ((projectItemRepresentations) && (projectItemRepresentations.count >0)) {
        
        int i = 0;
        
        [[self.view undoManager] setActionName:projectItemRepresentations.count > 1 ?
         NSLocalizedString(@"Adding Objects", @"Undo Action for adding objects to the timeline") :
         NSLocalizedString(@"Adding Object", @"Undo Action for adding one object to the timeline")
         ];
        
        [[self.view undoManager] beginUndoGrouping];
        
        VSTimelineObject *objectToBeSelected;
        
        //Iterates through the given projectItemRepresentations and tells the timeline to create new TimlineObjects based on ProjectItemRepresentaitons
        
        for(VSProjectItemRepresentation *projectItem in projectItemRepresentations){
            
            NSPoint position = [[positionArray objectAtIndex:i] pointValue];
            double width = [[widthArray objectAtIndex:i]doubleValue];
            
            
            double timePosition = [super timestampForPixelValue:position.x];
            double duration = [super timestampForPixelValue:width];
            
            //DDLogInfo(@"dura vgl: %f - %f",projectItem.duration,duration);
            //Sets the first object as the selected one wich's properites are shown
            if(i==0){
                objectToBeSelected = [self.timeline addNewTimelineObjectBasedOnProjectItemRepresentation:projectItem
                                                                                                 toTrack:trackViewController.track
                                                                                        positionedAtTime:timePosition
                                                                                            withDuration:projectItem.duration
                                                                                andRegisterUndoOperation:[self.view undoManager]
                                      ];
            }
            else {
                [self.timeline addNewTimelineObjectBasedOnProjectItemRepresentation:projectItem
                                                                            toTrack:trackViewController.track
                                                                   positionedAtTime:timePosition
                                                                       withDuration:duration
                                                           andRegisterUndoOperation:[self.view undoManager]
                 ];
            }
            i++;
        }
        
        [self selectTimelineObjectProxy:objectToBeSelected onTrack:trackViewController exclusively:YES];
        
        [[self.view undoManager] endUndoGrouping];
    }
    
    [self.view.window makeFirstResponder:self.view];
}


#pragma mark Selecting

-(BOOL) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy willBeSelectedOnTrackViewController:(VSMainTimelineTrackViewController *)trackViewController exclusively:(BOOL)exclusiveSelection{
    
    return [self selectTimelineObjectProxy:timelineObjectProxy onTrack:trackViewController exclusively:exclusiveSelection];
}

-(void) unselectTimelineObject:(VSTimelineObject *)timelineObject ofTrack:(VSMainTimelineTrackViewController *)trackViewController{
    [self setTimelineObjectUnselect:timelineObject ofTrack:trackViewController.track];
}


-(void) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy wasUnselectedOnTrackViewController:(VSMainTimelineTrackViewController *)trackViewController{
    
}

-(void) didClickViewOfTrackViewController:(VSMainTimelineTrackViewController *)trackViewController{
    [self unselectAllSelectedTimelineObjects];
}



-(NSArray*) files:(NSArray *)filePaths haveEnteredTrack:(VSMainTimelineTrackViewController *)track{
    return [self createProjectItemRepresentationsForFiles:filePaths];
}

-(NSArray*) files:(NSArray *)filePaths haveBeenDroppedOnTrack:(VSMainTimelineTrackViewController *)track{
    NSArray *result =  [self createProjectItemsForFiles:filePaths];
    
    [self.temporaryCreatedProjectItems removeAllObjects];
    
    
    return result;
}



#pragma mark Removing

-(void) timelineObjectProxies:(NSArray *)timelineObjectProxies wereRemovedFromTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
}

-(BOOL) removeTimelineObject:(VSTimelineObjectViewController *)timelineObjectViewController fromTrack:(VSMainTimelineTrackViewController *)track{
    
    [self removeTimlineObject:((VSTimelineObject*) timelineObjectViewController.timelineObjectProxy) fromTrack:track.track];
    
    return YES;
}



#pragma mark Resizing

-(VSDoubleFrame) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController willBeResizedFrom:(VSDoubleFrame)oldDoubleFrame to:(VSDoubleFrame)newDoubleFrame onTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
    if(newDoubleFrame.width < MINIMUM_TIMELINE_OBJECT_PIXEL_WIDTH){
        newDoubleFrame.width = MINIMUM_TIMELINE_OBJECT_PIXEL_WIDTH;
    }
    
    double newDuration = [super timestampForPixelValue:newDoubleFrame.x + newDoubleFrame.width ];
    
    [self changeWidhtOfTimeline:newDuration];
    
    return newDoubleFrame;
}

-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController wasResizedOnTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
    [self setTimelineDurationAccordingToTimelineWidth];
}




#pragma mark Moving

-(NSPoint) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController WillBeDraggedOnTrack:(VSMainTimelineTrackViewController *)trackViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition withSnappingDeltaX:(float)snappingDeltaX{
    
    float deltaX = newPosition.x - oldPosition.x;
    
    NSMutableArray *snappingDeltas = [[NSMutableArray alloc] init];
    
    //Calcluates the minimum Snapping-Distances of all selected objects on all tracks
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            
            float tmpSnappingDelta;
            if([tmpTrackViewController computeSnappingXValueForMoveableActiveTimelineObjectsMovedAccordingToDeltaX:deltaX snappingDeltaX:&tmpSnappingDelta]){
                [snappingDeltas addObject:[NSNumber numberWithFloat:tmpSnappingDelta]];
            }
        }
    }
    
    float minSnappingDeltaX = snappingDeltaX;
    
    for(NSNumber *number in snappingDeltas){
        if (abs([number floatValue]) > abs(minSnappingDeltaX)) {
            minSnappingDeltaX = [number floatValue];
        }
    }
    
    newPosition.x += minSnappingDeltaX;
    deltaX = newPosition.x - oldPosition.x;
    
    //tells all tracks to move their selected timelineObjects according to the newPosition and the distance to the snapping point
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController moveMoveableTimelineObjects:deltaX];
        }
    }
    
    return newPosition;
}

-(void) moveTimelineObjectTemporary:(VSTimelineObjectViewController *)timelineObject fromTrack:(VSMainTimelineTrackViewController *)fromTrack toTrackAtPosition:(NSPoint)position{
    
    //stores the new offset from the fromTrack to the track at the position of the given mouse position
    NSInteger newTrackOffset = [self computeTrackOffsetForTrack:fromTrack forMousePosition:position];

    //if the trackOffset has changed, the temporary timelienObejcts of all tracks have to be removed
    if(newTrackOffset != self.trackOffset){
        
        for(VSMainTimelineTrackViewController *trackViewController in self.trackViewControllers){
            [trackViewController resetTemporaryTimelineObjects];
            [trackViewController resetIntersections];
            
            //If the mouse is over the current track, the selected TimelineObjects of the all tracsk are set active
            if(newTrackOffset == 0)
                [trackViewController activateSelectedTimelineObjects];
        }
        
        //if the mouse isn't over the fromTrack the selected timelineObjects have to be moved temporarily according to the trackOffset
        if(newTrackOffset != 0){
            for(int i = 0; i<self.trackViewControllers.count; i++){
                VSMainTimelineTrackViewController *fromTrackViewController = (VSMainTimelineTrackViewController*) [self.trackViewControllers objectAtIndex:i];
                
                NSInteger newIndex = i + newTrackOffset;
                
                if(newIndex >= 0  && newIndex < self.trackViewControllers.count){
                    VSMainTimelineTrackViewController *toTrackViewController = (VSMainTimelineTrackViewController*) [self.trackViewControllers objectAtIndex:newIndex];
                    
                    
                    [self temporaryMoveSelectedTimelineObjectsFromTrack:fromTrackViewController
                                                                toTrack:toTrackViewController];
                }
            }
        }
    }
    
    self.trackOffset = newTrackOffset;
}


-(void) timelineObject: timelineObjectViewController wasDraggedOnTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController setTimelineObjectViewsIntersectedByMoveableTimelineObjects];
        }
    }
    
    [self enlargeTimelineIfNeccessary];
}


-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController didStopDraggingOnTrack:(VSMainTimelineTrackViewController *)trackViewController{
    self.autoscrolling = NO;
    //    [self.autoScrollingTimer invalidate];
    
    [self.view.undoManager beginUndoGrouping];
    [self.view.undoManager setActionName:NSLocalizedString(@"Moved Objects on Timeline", @"Undo Action Name for moving objects on Timeline")];
    
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController updateActiveMoveableTimelineObjectsAccordingToViewsFrame];
            [tmpTrackViewController removeInactiveSelectedTimelineObjectViewControllers];
            [tmpTrackViewController applyIntersectionToTimelineObjects];
            [tmpTrackViewController copyTemporaryTimelineObjectsToTrack];
            [tmpTrackViewController resetTemporaryTimelineObjects];
            [tmpTrackViewController unsetSelectedTimelineObjectsAsMoving];
            [tmpTrackViewController resetIntersections];
        }
    }
    
    [self.view.undoManager endUndoGrouping];
    
    [self setTimelineDurationAccordingToTimelineWidth];
    
    
}

-(void) timelineObject: timelineObjectViewController willStartDraggingOnTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
    self.trackOffset = 0;
    self.autoscrolling = YES;
    
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController setSelectedTimelineObjectsAsMoving];
        }
    }
    
}

-(BOOL) splitTimelineObject:(VSTimelineObjectViewController *) timelineObjectViewController ofTrack:(VSMainTimelineTrackViewController *)trackViewController byRects:(NSArray *)splittingRects{
    
    VSTimelineObject *tmpTimelineObject = ((VSTimelineObject*) timelineObjectViewController.timelineObjectProxy);
    
    if(!tmpTimelineObject){
        return NO;
    }
    
    if(!splittingRects || !splittingRects.count){
        return NO;
    }
    
    NSRect viewsFrame = timelineObjectViewController.view.frame;
    
    
    NSArray *newFrames = [self splitRect:viewsFrame by:splittingRects];
    
    
    //if no newFrames were computed, the view is removed instead of splitted
    if(!newFrames.count){
        [self.timeline removeTimelineObject:tmpTimelineObject fromTrack:trackViewController.track andRegisterAtUndoManager:self.view.undoManager];
    }
    else{
        [self segmentTimelineObject:timelineObjectViewController onTrack:trackViewController intoSegments:newFrames];
    }
    
    return YES;
}

-(void) copyTimelineObject:(VSTimelineObjectViewController *)timelineObjectViewController toTrack:(VSMainTimelineTrackViewController *)trackViewController{
    
    double startTime = [super timestampForPixelValue:timelineObjectViewController.timelineObjectView.doubleFrame.x];
    double duration = [super timestampForPixelValue:timelineObjectViewController.timelineObjectView.doubleFrame.width];
    
    if([timelineObjectViewController.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        [self.timeline copyTimelineObject:(VSTimelineObject*) timelineObjectViewController.timelineObjectProxy toTrack:trackViewController.track atPosition:startTime withDuration:duration andRegisterUndoOperation:self.view.undoManager];
    }
}


#pragma mark Devices

-(void) addDevices:(NSArray *)devices toTimelineObject:(VSTimelineObject *)timelineObject onTrack:(VSMainTimelineTrackViewController *)trackViewController{
    for(VSDeviceRepresentation *representation in devices){
        VSDevice *newDevice = [self.deviceManager deviceRepresentedBy:representation];
        
        if(newDevice){
            [timelineObject addDevicesObject:newDevice];
        }
    }
}

#pragma mark -
#pragma mark Private Methods

#pragma mark - Pixel Time Ratio


/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange{
    
    [super pixelTimeRatioDidChange];
    
    //tells all VSTrackViewControlls in the timeline, that the pixelItemRation has been changed
    for(VSMainTimelineTrackViewController *controller in self.trackViewControllers){
        [controller pixelTimeRatioDidChange:self.pixelTimeRatio];
        [controller.view setNeedsDisplay:YES];
    }
}


/**
 * Changes the the tracks width according to the given duration. The PixelTimeRatio is not changed
 *
 * @param duration Duration the tracks are resized according to.
 */
-(void) resizeTracksAccordingToDuration:(double) duration{
    [self.scrollView.trackHolderView setFrameSize:NSMakeSize([super pixelForTimestamp:duration], self.scrollView.trackHolderView.frame.size.height)];
}

/**
 * Updates the duration of the timeline according to the current pixel-width of the timeline
 */
-(void) setTimelineDurationAccordingToTimelineWidth{
    self.timeline.duration = [super timestampForPixelValue:self.scrollView.trackHolderWidth];
    [self computePixelTimeRatio];
}

/**
 * Called when VSTimelineObjectPropertiesDidTurnInactive Notification was received. Unselectes the currently selected timelineObjects.
 * @param notification NSNotifaction storing the information about which VSTimelineObjects were selected before the propertiesView turned inactive
 */
-(void) timelineObjectPropertIesDidTurnInactive:(NSNotification*) notification{
    [self unselectAllSelectedTimelineObjects];
}



/**
 * Enlarges the width of the timeline, but doesn't change the timeline's duration
 * @param newDuration Duration of the timeline the width of the timeline is enlarged according to
 */
-(void) changeWidhtOfTimeline:(double) newDuration{
    //if the computed Maximum is greater than the current duration of the timeline it is enlarged
    if(newDuration > self.timeline.duration){
        [self resizeTracksAccordingToDuration:newDuration];
    }
    else{
        [self resizeTracksAccordingToDuration:self.timeline.duration];
    }
}

#pragma mark - TimelineObjects

#pragma mark Creating

/**
 * Creates a new TimelineObjectProxy according based on the vigen VSProjectItemRepresentation and positions it at the given positon*
 * @param trackViewController VSTrackViewController the newly the returned VSTimelineObjectProxy is created for
 * @param item VSProjectItemRepresentation the proxy will be based on
 * @param position NSPoint the proxy is places on the timeline
 * @return The newly create VSTimelineObjectProxy if the creation was successfully, nil otherwise
 */
-(VSTimelineObjectProxy*) trackViewController:(VSMainTimelineTrackViewController *)trackViewController createTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item atPosition:(NSPoint)position{
    
    double timePosition = [super timestampForPixelValue:position.x];
    
    return [self.timeline createNewTimelineObjectProxyBasedOnProjectItemRepresentation:item
                                                                      positionedAtTime:timePosition
                                                                          withDuration:item.duration];
}

/**
 * Creates a VSTimelineObjectProxy for the given baseProjectItem and inits it with the given startPosition and duration
 * @param baseProjectItem VSProjectItemRepresentation the VSTimelineObjectProxy is created for
 * @param startTime Starttime of the newly created VSProjectItemRepresentation
 * @param duration Starttime of the newly created VSProjectItemRepresentation
 * @return A VSTimelineObjectProxy based on the initialized with the given values if its creation was sucessfull, nil otherweis
 */
-(VSTimelineObjectProxy*) createTimelineObjectProxyBasedOnProjectItemPresentation:(VSProjectItemRepresentation*) baseProjectItem atStarttime:(double) startTime withDuration:(double) duration{
    
    return [self.timeline createNewTimelineObjectProxyBasedOnProjectItemRepresentation:baseProjectItem positionedAtTime:startTime withDuration:duration];
}

/**
 * Creates a VSProjectItemRepresentation for all paths in the given array
 *
 * Looks through the currentTemporaryProjectItems if any of the files has an VSProjectItemRepresentation already created for it. If not it creates. Aftrewards the currentTemporaryProjectItems are removed and the VSProjectItemRepresentation for the given array of files is added - as key is used the filePath.
 * @param filePaths NSArray storing the filePaths VSProjectItemRepresentation's are created for
 * @return NSArray holding the VSProjectItemRepresentation's for the given filePaths
 */
-(NSArray*) createProjectItemRepresentationsForFiles:(NSArray*) filePaths{
    
    return [self.projectItemRepresentationController representationsForFiles:filePaths];
    
}

/**
 * Creates a VSProjectItemRepresentation for all paths in the given array
 *
 * Looks through the currentTemporaryProjectItems if any of the files has an VSProjectItemRepresentation already created for it. If not it creates. Aftrewards the currentTemporaryProjectItems are removed and the VSProjectItemRepresentation for the given array of files is added - as key is used the filePath.
 * @param filePaths NSArray storing the filePaths VSProjectItemRepresentation's are created for
 * @return NSArray holding the VSProjectItemRepresentation's for the given filePaths
 */
-(NSArray*) createProjectItemsForFiles:(NSArray*) filePaths{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *currentTemporaryProjectItems = [NSMutableDictionary dictionaryWithDictionary:self.temporaryCreatedProjectItems];
    
    [self.temporaryCreatedProjectItems removeAllObjects];
    
    for(NSString *fileName in filePaths){
        
        VSProjectItemRepresentation *tmpProjectItemRepresentation = [currentTemporaryProjectItems objectForKey:fileName];
        
        VSProjectItem *tempProjectItem = nil;
        
        if(tmpProjectItemRepresentation){
            tempProjectItem = [self.projectItemController addNewProjectForRepresentation:tmpProjectItemRepresentation];
        }
        else{
            tempProjectItem = [self.projectItemController addsAndReturnsNewProjectItemFromFile:fileName];
        }
        
        if(tempProjectItem){
            [result addObject:tempProjectItem];
        }
    }
    
    return result;
}



#pragma mark Selecting

/**
 * Sets the given VSTimelineObjectProxy selected an unselects the currenlty selected objects if the new seleciton is exclusive
 * @param timelineObjectProxy VSTimelineObjectProxy to be selected
 * @param trackViewController VSTrackViewController representing the track holding the timelineObjectProxy
 * @param exclusiveSelection IF yes the currently selected objects are set as unselected
 * @return YES if the selection was done successfully, NO otherwise
 */
-(BOOL) selectTimelineObjectProxy:(VSTimelineObjectProxy*) timelineObjectProxy onTrack:(VSMainTimelineTrackViewController*) trackViewController exclusively:(BOOL) exclusiveSelection{
    
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [self.view.undoManager beginUndoGrouping];
        if(exclusiveSelection){
            
            [self.timeline unselectAllTimelineObjects];
        }
        
        [self.timeline selectTimelineObject:((VSTimelineObject*) timelineObjectProxy) onTrack:trackViewController.track];
        
        [self.view.undoManager endUndoGrouping];
        
        [self postNotificationForSelectionOfTimelineObject:[self.timeline.selectedTimelineObjects lastObject]];
        
        return YES;
    }
    else {
        return NO;
    }
    
}

-(void) setTimelineObjectUnselect:(VSTimelineObject*) timelineObject ofTrack:(VSTrack*) track{
    [self.view.undoManager setActionName:NSLocalizedString(@"Change Selection", @"Undo Massage of unselecting TimelineObjects")];
    
    [self.view.undoManager beginUndoGrouping];
    
    [self.timeline unselectTimelineObject:timelineObject onTrack:track];
    
    [self postNotificationForSelectionOfTimelineObject:[self.timeline.selectedTimelineObjects lastObject]];
    
    [self.view.undoManager endUndoGrouping];
}

-(void) unselectAllSelectedTimelineObjects{
    [self.timeline unselectAllTimelineObjects];
    
    [self postNotificationForSelectionOfTimelineObject:nil];
}

-(void) postNotificationForSelectionOfTimelineObject:(VSTimelineObject*) timelineObject{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [VSDocumentController documentOfView:self.view]
                                                         forKey:VSSendersDocumentKeyInUserInfoDictionary];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotSelected
                                                        object:timelineObject
                                                      userInfo:userInfo];
}

#pragma mark Moving

/*
 * Divides the VSTimelineObjectViewController in VSTimelineObjectViewController's according to the given segments
 * @param timelineObjectViewController VSTimelineObjectViewController which will be segmented.
 * @param trackViewController VSTrackViewController the given VSTimelineObjectViewController is on
 * @param segments NSArray of rects the VSTimelineObjectViewController is divided into
 */
-(void) segmentTimelineObject:(VSTimelineObjectViewController*) timelineObjectViewController onTrack:(VSMainTimelineTrackViewController*) trackViewController intoSegments:(NSArray*) segments{
    int i = 0;
    
    VSTimelineObject *tmpTimelineObject = timelineObjectViewController.timelineObject;
    
    for(NSValue *value in segments){
        
        NSRect frameRect = [value rectValue];
        double newStartTime = [super timestampForPixelValue:frameRect.origin.x];
        double newDuration = [super timestampForPixelValue:frameRect.size.width];
        
        //the timelineObject is change according to the first frame, for all other new frames copies of timelineObject are created
        if(i == 0){
            if(tmpTimelineObject.duration != newDuration){
                [tmpTimelineObject changeDuration:newDuration andRegisterAtUndoManager:self.view.undoManager];
            }
            
            if(tmpTimelineObject.startTime != newStartTime){
                [tmpTimelineObject changeStartTime:newStartTime andRegisterAtUndoManager:self.view.undoManager];
            }
        }
        else{
            [self.timeline copyTimelineObject:tmpTimelineObject toTrack:trackViewController.track atPosition:newStartTime withDuration:newDuration andRegisterUndoOperation:self.view.undoManager];
        }
        i++;
    }
}

/**
 * Computes the rects of the given rect after by splitted by the splittingRects
 * @param aRect NSRect to be splitted
 * @param splittingRects NSArray of NSRects aRect is splitted according to.
 * @return NSArray of NSRects holding the segments of aRect after being splitted by splittenRects
 */
-(NSArray*) splitRect:(NSRect) aRect by:(NSArray*) splittingRects{
    //orders the splittingRects ascending by their x-Positions
    splittingRects =  [splittingRects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSNumber *obj1X = [NSNumber numberWithInt:[obj1 rectValue].origin.x];
        NSNumber *obj2X = [NSNumber numberWithInt:[obj2 rectValue].origin.x];
        return [obj1X compare:obj2X];
    } ];
    
    
    int i = 0;
    
    //Computes the frames of the parts the view of the given timelineObjectViewController will be splitted up to
    NSMutableArray* newFrames = [[NSMutableArray alloc] init];
    
    for (NSValue *value in splittingRects){
        NSRect splittingRect = [value rectValue];
        
        //the first part will go from the x-Position of the view's Frame to the x-Position of the splittingRect
        if(i== 0){
            NSRect leftFrame = aRect;
            leftFrame.size.width = splittingRect.origin.x - leftFrame.origin.x;
            
            [newFrames addObject:[NSValue valueWithRect:leftFrame]];
        }
        
        //All other except the first one cutoff the part left of it
        NSRect leftFrame = [[newFrames lastObject] rectValue];
        leftFrame.size.width = splittingRect.origin.x - leftFrame.origin.x;
        
        [newFrames removeObjectAtIndex:newFrames.count-1];
        
        if(leftFrame.size.width > 0){
            [newFrames addObject:[NSValue valueWithRect:leftFrame]];
        }
        
        //The new part starts at the right end of the splitRect and goes until the end of the view
        NSRect rightFrame = leftFrame;
        rightFrame.origin.x = NSMaxX(splittingRect);
        rightFrame.size.width = NSMaxX(aRect) - rightFrame.origin.x;
        
        if(rightFrame.size.width > 0){
            [newFrames addObject:[NSValue valueWithRect:rightFrame]];
        }
        
        i++;
    }
    
    return newFrames;
}

/**
 * Changes the width of the timelin if on of the moved timelineObjects is moved outside of the timeline
 */
-(void) enlargeTimelineIfNeccessary{
    float maxFrameX = 0.0;
    
    //Computes the farest left point of all currenlty moved timelineObjects
    for(VSMainTimelineTrackViewController *tmpTrackViewController in self.trackViewControllers){
        NSArray *moveableObjects = [tmpTrackViewController movableTimelineObjectViewControllers];
        
        for(VSTimelineObjectViewController *timelineObjectViewController in moveableObjects){
            float maxX =  NSMaxX( timelineObjectViewController.view.frame);
            
            if(maxX > maxFrameX){
                maxFrameX = maxX;
            }
        }
        
        
        double newTimeMax = [super timestampForPixelValue:maxFrameX];
        
        [self changeWidhtOfTimeline:newTimeMax];
        
    }
}



#pragma mark Moving to different Track

/**
 * Copmutes the track offset for the fromTrack according to the mouse position.
 *
 * The track offset is the difference between indizes in the trackViewControllers-Array of the fromTrack and the track the mousePosition is over
 * @param fromTrack VSTrackViewController the offset is computed for
 * @param mousePosition Current position of the mouse.
 * @return Returns the difference between indizes in the trackViewControllers-Array of the fromTrack and the track the mousePosition is over. 0: mouse is over the fromTrack or over none other track.
 */
-(NSInteger) computeTrackOffsetForTrack:(VSMainTimelineTrackViewController*) fromTrack forMousePosition:(NSPoint) mousePosition{
    
    
    NSPoint positionInView = [self.scrollView.documentView convertPoint:mousePosition fromView:nil];
    
    //if the mouse is over the fromTrack the offset is 0
    if(NSPointInRect(positionInView,  fromTrack.view.frame)){
        return 0;
    }
    
    NSInteger fromTrackArrayIndex = [self.trackViewControllers indexOfObject:fromTrack];
    NSInteger newTrackOffset = self.trackOffset;
    
    
    //iterates through all tracks and checks if the mouse is above it.
    //If the mouse is above one Track the difference between its Array-Index in trackViewControllers-Array and the fromTrackArrayIndex is stored in newTrackOffset
    for(int i = 0; i < self.trackViewControllers.count; i++){
        //the given track has already been checked above
        if(i != fromTrackArrayIndex){
            VSMainTimelineTrackViewController *trackViewController = (VSMainTimelineTrackViewController*) [self.trackViewControllers objectAtIndex:i];
            if(NSPointInRect(positionInView,  trackViewController.view.frame)){
                newTrackOffset = i - fromTrackArrayIndex;
                break;
            }
        }
    }
    
    //validates the newTrackOffset that none of the selectedTimelineObjects on the tracks is moved to far
    newTrackOffset = [self validateTrackOffset:newTrackOffset];
    
    
    return newTrackOffset;
}

/**
 * Validates the the given trackOffset to make sure that none of the selectedTimelineObjects on the tracks is moved to nonexisting track, like track at Index -1 or at an index greater than timelineObjectViewControllers.count
 * @param trackOffset Current trackOffset
 * @return Validates the given trackOffset and returns it validated
 */
-(NSInteger) validateTrackOffset:(NSInteger) trackOffset{
    if(trackOffset >0){
        
        for(NSInteger i = self.trackViewControllers.count-1; i>=self.trackViewControllers.count-trackOffset; i--){
            if([[self.trackViewControllers objectAtIndex:i] isKindOfClass:[VSMainTimelineTrackViewController class]]){
                if([((VSMainTimelineTrackViewController *)[self.trackViewControllers objectAtIndex:i]) selectedTimelineObjectViewControllers].count){
                    if(i+trackOffset > self.trackViewControllers.count-1){
                        trackOffset -= i + trackOffset - (self.trackViewControllers.count-1);
                    }
                }
            }
        }
    }
    else if(trackOffset < 0){
        for(int i =0; i<trackOffset*(-1); i++){
            if([[self.trackViewControllers objectAtIndex:i] isKindOfClass:[VSMainTimelineTrackViewController class]]){
                if([((VSMainTimelineTrackViewController *)[self.trackViewControllers objectAtIndex:i]) selectedTimelineObjectViewControllers].count){
                    if(i+trackOffset < 0){
                        trackOffset -= i + trackOffset;
                    }
                }
            }
        }
    }
    
    return trackOffset;
}

/**
 * Moves the selectedTimelineObjects of the formTrack temporarily to toTrack.
 *
 * The TimlineObjects are not really moved. The selectedTimelineObjects of the fromTrack are set inactive thus they are invisible and added to temporaryTimelineObjects of the toTrack
 * @param fromTrack VSTrackViewController the selectedTimelineObjects are moved from.
 * @param toTrack VSTrackViewController the selectedTimelineObjects of the fromTrack are moved to.
 */
-(void) temporaryMoveSelectedTimelineObjectsFromTrack:(VSMainTimelineTrackViewController*) fromTrack toTrack:(VSMainTimelineTrackViewController*) toTrack{
    
    for (VSTimelineObjectViewController *timelineObjectViewController in [fromTrack selectedTimelineObjectViewControllers]) {
        
        VSTimelineObjectViewController *newTimelineObjectViewController = [toTrack addTemporaryTimelineObject:timelineObjectViewController.timelineObjectProxy withDoubleFrame:timelineObjectViewController.viewsDoubleFrame];
        
        newTimelineObjectViewController.timelineObjectProxy.selected = timelineObjectViewController.timelineObjectProxy.selected;
    }
    
    [fromTrack deactivateSelectedTimelineObjects];
}


#pragma mark Removing

/**
 * Removes the currently selected TimelineObjects and registers the removal at the view's undoManager
 */
-(void) removeSelectedTimelineObjects{
    [self.view.undoManager beginUndoGrouping];
    [self postNotificationForSelectionOfTimelineObject:nil];
    [self.timeline removeSelectedTimelineObjectsAndRegisterAtUndoManager:self.view.undoManager];
    [self.view.undoManager setActionName:NSLocalizedString(@"Remove Objects", @"Undo Action for removing TimelineObjects from the timeline")];
    [self.view.undoManager endUndoGrouping];
}

/**
 * Removes the given timelineObject from the given Track
 * @param timelineObject VSTimlineObjec to be removed
 * @param track Trakc the timelineObject will be removed from
 */
-(void) removeTimlineObject:(VSTimelineObject*) timelineObject fromTrack:(VSTrack*) track{
    [self.view.undoManager beginUndoGrouping];
    
    if([timelineObject isEqualTo:[self.timeline.selectedTimelineObjects lastObject]]){
        [self postNotificationForSelectionOfTimelineObject:[self.timeline.selectedTimelineObjects objectAtIndex:self.timeline.selectedTimelineObjects.count-1]];
    }
    
    [self.timeline removeTimelineObject:timelineObject
                              fromTrack:track
               andRegisterAtUndoManager:self.view.undoManager];
    
    [self.view.undoManager setActionName:NSLocalizedString(@"Remove Objects", @"Undo Action for removing TimelineObjects from the timeline")];
    
    [self.view.undoManager endUndoGrouping];
}

#pragma mark - Playhead

/**
 * Computes the nearest left or right end of all VSTimelineObjectViews on the timeline and jumps to the nearest one
 *
 * @param forward Indicates wheter the nearest VSTimelineObjectView is looke for left or right from the current position of the playhead
 */
-(void) moveToNextCutAndSearchForward:(BOOL) forward{
    float distanceToNextCut = 0;
    
    for(VSMainTimelineTrackViewController *trackViewController in self.trackViewControllers){
        float distance = [trackViewController distanceToNearestCutFromPosition:[self currentPlayheadMarkerLocation] forward:forward];
        
        if(abs(distance) > 0.01){
            
            if(distanceToNextCut == 0){
                distanceToNextCut = distance;
            }
            else if(abs(distance) < abs(distanceToNextCut)){
                distanceToNextCut = distance;
            }
        }
    }
    
    [self letPlayheadJumpOverDistance:distanceToNextCut];
}


#pragma mark - Tracks

/**
 * Creates a new VSTrackView according to the given track.
 * @param track VSTrack the VSTrackView will be created for
 */
-(void) createTrack:(VSTrack*) track{
    
    //Size and position of the track
    int width = self.scrollView.visibleTrackViewsHolderWidth;
    
    
    
    VSMainTimelineTrackViewController* newTrackViewController = [[VSMainTimelineTrackViewController alloc]initWithDefaultNibAccordingToTrack:track andTrackHeight:VSTrackViewHeight];
    
    //set the autoresizing masks
    [[newTrackViewController view] setAutoresizingMask:NSViewWidthSizable];
    [[newTrackViewController view] setAutoresizesSubviews:YES];
    
    NSInteger yPosition = (VSTrackViewHeight+VSTrackViewMargin) * ([self.trackViewControllers count]);
    
    NSRect newFrame = NSMakeRect(0,yPosition,width,VSTrackViewHeight);
    
    [[newTrackViewController view] setFrame:(newFrame)];
    
    // The VSTimelineViewControlller acts as the delegate of the VSTrackViewController
    newTrackViewController.delegate = self;
    newTrackViewController.pixelTimeRatio = self.pixelTimeRatio;
    
    [self.scrollView addTrackView:newTrackViewController.view];
    
    [self.trackViewControllers addObject:newTrackViewController];
    
    [self addNewTrackLabelForTrack:newTrackViewController];
    
}

/**
 * Creates a new label for the given Track and sends it to the trackLabelsViewController to display the label
 * @param aTrack VSTrackViewController the label is added for
 */
-(void) addNewTrackLabelForTrack:(VSMainTimelineTrackViewController*) aTrack{
    NSRect labelRect = NSMakeRect(0, aTrack.view.frame.origin.y, TRACK_LABEL_WIDTH, aTrack.view.frame.size.height);
    
    [self.scrollView addTrackLabel:[[VSTrackLabel alloc] initWithName:aTrack.track.name forTrack:aTrack.track.trackID forFrame:labelRect]];
}


#pragma mark - Autoscrolling

-(void) scrollIfMouseOutsideContentView{
    
    
    NSPoint globalLocation = [ NSEvent mouseLocation ];
    NSPoint windowLocation = [ [ self.scrollView window ] convertScreenToBase: globalLocation ];
    NSPoint viewLocation = [ self.scrollView.trackHolderView convertPoint: windowLocation fromView: nil ];
    
    NSRect leftAutoScrollingArea = [self.scrollView documentVisibleRect];
    leftAutoScrollingArea.size.width *= 0.1;
    
    NSRect rightAutoScrollingArea  = leftAutoScrollingArea;
    rightAutoScrollingArea.origin.x = NSMaxX([self.scrollView documentVisibleRect])-rightAutoScrollingArea.size.width;
    
    BOOL mouseIsInAutoScrollArea = NO;
    
    
    
    if(NSPointInRect( viewLocation, rightAutoScrollingArea)){
        DDLogInfo(@"Mouse in right auto scrolling area");
        mouseIsInAutoScrollArea = YES;
        self.autoscrollMouseLocation = [NSEvent mouseLocation];
        //        self.autoScrollingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(autoscrollScrollView) userInfo:nil repeats:YES];
        //
        //        [self.autoScrollingTimer fire];
        
    }
    else if(NSPointInRect( viewLocation, leftAutoScrollingArea)){
        DDLogInfo(@"Mouse in left auto scrolling area");
        mouseIsInAutoScrollArea = YES;
    }
    
    //    if(!mouseIsInAutoScrollArea && self.autoScrollingTimer && self.autoScrollingTimer.isValid){
    //        DDLogInfo(@"Turned off autoscrolling timer");
    ////        [self.autoScrollingTimer invalidate];
    //    }
}

-(void) autoscrollScrollView{
    self.autoscrollMouseLocation = NSMakePoint(self.autoscrollMouseLocation.x+50, [NSEvent mouseLocation].y);
    
    NSEvent *event = [NSEvent mouseEventWithType:NSMouseMoved location:self.autoscrollMouseLocation modifierFlags:0 timestamp:0 windowNumber:self.view.window.windowNumber context:nil eventNumber:0 clickCount:0 pressure:0];
    [self.scrollView.contentView autoscroll:event];
}

#pragma mark - Properties

-(double) duration{
    return self.timeline.duration;
}

-(float) pixelLength{
    return self.scrollView.trackHolderWidth;
}

-(VSTimelineScrollView*) timelineScrollView{
    return self.scrollView;
}

-(double) playheadTimePosition{
    return self.timeline.playHead.currentTimePosition;
}

-(VSPlayHead*) playhead{
    return self.timeline.playHead;
}

-(float) currentPlayheadMarkerLocation{
    return self.scrollView.playheadMarkerLocation;
}

@end
