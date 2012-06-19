//
//  VSTrackViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackViewController.h"

#import "VSTrackView.h"
#import "VSProjectItemController.h"
#import "VSProjectItemRepresentationController.h"
#import "VSProjectItemRepresentation.h"
#import "VSTrack.h"
#import "VSTimelineObjectViewController.h"
#import "VSTimelineObject.h"
#import "VSTimelineObjectProxy.h"
#import "VSTimelineObjectView.h"

#import "VSCoreServices.h"

@interface VSTrackViewController ()

/** Instance of VSProjectItemController */ 
@property VSProjectItemController *projectItemController;

/** Instance of VSProjectItemRepresentationController */
@property VSProjectItemRepresentationController *projectItemRepresentationController;


/** NSMutableArray storing all VSTimelineObjectViewControllers of the VSTimelineObjectViews added to the VSTrackViewController */ 
@property (strong) NSMutableArray *timelineObjectViewControllers;

/** NSMutableArray storing all VSTimelineObjectViewControllers of the VSTimelineObjectViews which's VSTimelineObjects were dragged onto the VSTrackView but not dropped yet. Neccessary to give the user a preview where the newly added VSTimelineObject will be placed on the timeline */
@property (strong) NSMutableArray *temporaryTimelineObjectViewControllers;

@end

@implementation VSTrackViewController

@synthesize delegate = _delegate;
@synthesize track = _track;
@synthesize timelineObjectViewControllers = _timelineObjectViewControllers;
@synthesize pixelTimeRatio = _pixelTimeRatio;
@synthesize projectItemController = _projectItemController;
@synthesize projectItemRepresentationController = _projectItemRepresentationController;
@synthesize temporaryTimelineObjectViewControllers = _temporaryTimelineObjectViewControllers;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTrackView";

#pragma mark - Init

-(id) initWithDefaultNibAccordingToTrack:(VSTrack*) track{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        if([self.view isKindOfClass:[VSTrackView class]]){
            
            self.track = track;
            
            [self.track addObserver:self forKeyPath:@"timelineObjects" options:NSKeyValueObservingOptionPrior |NSKeyValueObservingOptionNew context:nil];
            
            self.timelineObjectViewControllers = [[NSMutableArray alloc] init];
            self.temporaryTimelineObjectViewControllers = [[NSMutableArray alloc] init];
            
            self.projectItemController = [VSProjectItemController sharedManager];
            
            self.projectItemRepresentationController = [VSProjectItemRepresentationController sharedManager];
            
            ((VSTrackView*) self.view).controllerDelegate = self;
            
            
        }
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
}

#pragma mark - Methods

-(void) pixelTimeRatioDidChange:(double)newRatio{
    
    //only proceeds if the ratio has changed
    if(self.pixelTimeRatio != newRatio){
        self.pixelTimeRatio = newRatio;
        
        //tells all its VSTimelineObjectViewController's that the ratio has changed
        for(VSTimelineObjectViewController *controller in self.timelineObjectViewControllers){    
            [controller changePixelTimeRatio:self.pixelTimeRatio];
        }
    }
}


#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //Observes if any changes on the timelineObjects of the VSTrack the VSTrackViewController displays occures
    if([keyPath isEqualToString:@"timelineObjects"]){
        
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){ 
                    NSArray *allTimelineObjects = [object valueForKey:keyPath];
                    NSArray *newTimelineObjects = [allTimelineObjects objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    for(VSTimelineObject *object in newTimelineObjects){
                        [self addNewTimelineObject:object];
                    }
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if([[change valueForKey:@"notificationIsPrior"] boolValue]){ 
                    NSArray *allTimelineObjects = [object valueForKey:keyPath];
                    NSArray *removedTimelineObjects = [allTimelineObjects objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    for(VSTimelineObject *object in removedTimelineObjects){
                        [self removeTimelineObject:object];
                    }
                    
                    if([self delegateRespondsToSelector:@selector(timelineObjectProxies:wereRemovedFromTrack:)]){
                        [self.delegate timelineObjectProxies:removedTimelineObjects wereRemovedFromTrack:self];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
}


-(BOOL) trackView:(VSTrackView *)trackView objectsHaveBeenDropped:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint)position{
    
    BOOL result = NO;
    
    if(trackView){
        
        //stores the 
        NSMutableArray *droppedProjectItems = [[NSMutableArray alloc] init];
        
        //if the draggingPasteboard stored in draggingInfo contains VSProjectItemRepresentation-Objects, they are temporary stored in droppedProjectItems
        if([[draggingInfo draggingPasteboard] canReadObjectForClasses:[NSArray arrayWithObject:[VSProjectItemRepresentation class]] options:nil]){
            droppedProjectItems = [NSMutableArray arrayWithArray:[[draggingInfo draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[VSProjectItemRepresentation class]] options:nil]];
        }
        
        //if the draggingPasteboard stored in draggingInfo contains file-paths (NSFilenamesPboardType) the paths are read out. VSProjectItemRepresentation are created for every filePath and added to droppedProjectItems
        if([[[draggingInfo draggingPasteboard] types ] containsObject:NSFilenamesPboardType]){
            
            //Stores data of NSFilenamesPboardType stored in draggingPasteboard of draggingInfo
            NSData *data = [[draggingInfo draggingPasteboard] dataForType:NSFilenamesPboardType];
            
            //reads out the file-paths of data
            NSArray *fileNames = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:kCFPropertyListImmutable errorDescription:nil];
            
            //for every filePath a temporary VSProjectItem is created to create a VSProjectItemRepresentation
            for(NSString *fileName in fileNames){
                VSProjectItem *tmpItem = [self.projectItemController addsAndReturnsNewProjectItemFromFile:fileName];
                VSProjectItemRepresentation *tmpRepresentation = [self.projectItemRepresentationController createPresentationOfProjectItem:tmpItem];
                
                if(tmpRepresentation){
                    [droppedProjectItems addObject:tmpRepresentation];
                }
            }
            
        }
        
        
        if(droppedProjectItems.count > 0){
            
            
            [self.view.undoManager beginUndoGrouping];
            
            int i = 0;
            
            NSMutableArray *timelineObjectsWidth  = [[NSMutableArray alloc] init];
            NSMutableArray *timelineObjectsPositions  = [[NSMutableArray alloc] init];
            
            //for every VSProjectItemRepresentation in droppedProjectItems a VSTimelineObject is created
            for(VSProjectItemRepresentation *item in droppedProjectItems){
                
                id result = [self.temporaryTimelineObjectViewControllers objectAtIndex:i];
                
                if([result isKindOfClass:[VSTimelineObjectViewController class]]){
                    VSTimelineObjectViewController *tmpController = (VSTimelineObjectViewController*) result;
                    
                    [timelineObjectsWidth addObject: [NSNumber numberWithInt:tmpController.view.frame.size.width]];
                    [timelineObjectsPositions addObject: [NSValue valueWithPoint:tmpController.view.frame.origin]];
                    
                }
                i++;
            }
            
            if([self delegateRespondsToSelector:@selector(trackViewController:addTimelineObjectsBasedOnProjectItemRepresentation:atPositions:withWidths:)]){
                [self.delegate trackViewController:self addTimelineObjectsBasedOnProjectItemRepresentation:droppedProjectItems atPositions:timelineObjectsPositions withWidths:timelineObjectsWidth];
                
                result = YES;
            }
            
            //changes the start points and duration for all intersected TimelinObejcts according to their intersectedRects
            [self applyIntersectionToTimelineObjects];
        }
        
        //sets the intersected - property of all VSTimleineObjectControlls to NO
        [self resetIntersectedTimelineObjects];
        
        //Sets the actino name of the undo action
        [self.view.undoManager setActionName:droppedProjectItems.count > 1
         ? NSLocalizedString(@"Adding Objects", @"Undo Action for adding objects to the timeline") 
                                            : NSLocalizedString(@"Adding Object", @"Undo Action for adding one object to the timeline")];
        [self.view.undoManager endUndoGrouping];
    }
    
    
    //clears VSTrackView'S temporary stored timelineObjects 
    [self resetTemporaryTimelineObjects];
    
    return result;
}

-(void) trackView:(VSTrackView *)trackView objectsOverTrack:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint)position{
    
    if(!trackView)
        return;
    
    //sets the positions for all views of VSTimelineObjectViewControllers stored in self.temporaryTimelineObjectViewControllers 
    if([self.temporaryTimelineObjectViewControllers count] > 0){
        
        int currentTotalWidth = 0;
        
        //if more than one VSTimelineObjectViewControllers is stored in self.temporaryTimelineObjectViewControllers their views are positioned next to each other
        for(VSTimelineObjectViewController *timelineObjectViewController in self.temporaryTimelineObjectViewControllers){
            
            //sets the frame for timelineObjectViewController's view
            NSRect newFrame =  timelineObjectViewController.view.frame;
            newFrame.origin.x = position.x + currentTotalWidth;
            newFrame.size.width = timelineObjectViewController.timelineObjectProxy.duration / self.pixelTimeRatio;
            currentTotalWidth += newFrame.size.width;
            
            
            
            [timelineObjectViewController.view setFrame:newFrame];
            
        }
        
        //Checks if any of the existing timeline objects intersected by any of the views stored in temporaryTimelineObjectViewControllers
        [self setTimelineObjectViewsIntersectedByTimelineObjectViews:self.temporaryTimelineObjectViewControllers];
    }
}

-(NSDragOperation) trackView:(VSTrackView *)trackView objectsHaveEntered:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint)position{
    
    if(!trackView)
        return NSDraggingFormationNone;
    
    NSMutableArray *draggedProjectItems = [[NSMutableArray alloc] init];
    
    //if the draggingPasteboard stored in draggingInfo contains VSProjectItemRepresentation-Objects, they are read out and stored in draggedProjectItems
    if([[draggingInfo draggingPasteboard] canReadObjectForClasses:[NSArray arrayWithObject:[VSProjectItemRepresentation class]] options:nil]){
        draggedProjectItems = [NSMutableArray arrayWithArray:[[draggingInfo draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[VSProjectItemRepresentation class]] options:nil]];
    }
    
    //if the draggingPasteboard stored in draggingInfo contains file-paths (NSFilenamesPboardType) the paths are read out. VSProjectItemRepresentation are created for every filePath and added to draggedProjectItems
    if([[[draggingInfo draggingPasteboard] types ] containsObject:NSFilenamesPboardType]){
        NSData *data = [[draggingInfo draggingPasteboard] dataForType:NSFilenamesPboardType];
        
        NSArray *fileNames = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:kCFPropertyListImmutable errorDescription:nil];
        
        for(NSString *fileName in fileNames){
            VSProjectItem *tempProjectItem = [self.projectItemController createNewProjectItemFromFile:fileName];
            if(!tempProjectItem){
                return NSDragOperationNone;
            }
            [draggedProjectItems addObject:[self.projectItemRepresentationController createPresentationOfProjectItem:tempProjectItem]];
            
        }
    }
    
    //for each VSProjectItemRepresentation found and stored in draggedProjectItems a new VSTimelineObjectProxy is created and added to self.temporaryTimelineObjectViewControllers 
    for(VSProjectItemRepresentation *item in draggedProjectItems){
        [self addNewTemporaryTimelineObjectProxyBasedOn:item atPosition:position toTrack:trackView];
    }
    
    //if no valid object was found, NSDragOperationNone is returned
    if([draggedProjectItems count]> 0){
        return NSDragOperationMove;
    }
    else
        return NSDragOperationNone;
}


-(BOOL) trackView:(VSTrackView *)trackView objectHaveExited:(id<NSDraggingInfo>)draggingInfo{
    
    if(!trackView)
        return NO;
    
    //sets the intersected property of all VSTimelineObjectControllers to NO
    [self resetIntersectedTimelineObjects];
    
    //removes the temporary timelineObjects of the trackView
    return [self resetTemporaryTimelineObjects];
}

-(void) didClicktrackView:(VSTrackView *)trackView{
    if([self delegateRespondsToSelector:@selector(didClickViewOfTrackViewController:)]){
        [self.delegate didClickViewOfTrackViewController:self];
    }
}

#pragma mark- VSTimelineObjectControllerDelegate implementation

-(BOOL)timelineObjectProxyWillBeSelected:(VSTimelineObjectProxy *)timelineObjectProxy{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxy:willBeSelectedOnTrackViewController:)]){
        return [self.delegate timelineObjectProxy:timelineObjectProxy willBeSelectedOnTrackViewController:self];
    }
    return NO;
}

-(void) timelineObjectProxyWasSelected:(VSTimelineObjectProxy *)timelineObjectProxy{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxy:wasSelectedOnTrackViewController:)]){
        [self.delegate timelineObjectProxy:timelineObjectProxy wasSelectedOnTrackViewController:self];
    }
}

-(void) timelineObjectProxyWasUnselected:(VSTimelineObjectProxy *)timelineObjectProxy{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxy:wasUnselectedOnTrackViewController:)]){
        [self.delegate timelineObjectProxy:timelineObjectProxy wasUnselectedOnTrackViewController:self];
    }
}


-(void) timelineObjectDidStopDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    
    double startTime = [self timeValueForPixelValue:timelineObjectViewController.view.frame.origin.x];
    
    [self.view.undoManager beginUndoGrouping];
    
    //if the view has been moved, the start time of VSTimelineObjectProxy is updated
    if(startTime != timelineObjectViewController.timelineObjectProxy.startTime){
        [timelineObjectViewController.timelineObjectProxy changeStartTime:startTime andRegisterAtUndoManager:self.view.undoManager];
    }
    
    //applys the interscetions
    [self applyIntersectionToTimelineObjects];
    
    [self.view.undoManager setActionName:NSLocalizedString(@"Move Object", @"Undo action name for moving obejcts on timeline")];
    [self.view.undoManager endUndoGrouping];
    
    //brings the dragge VSTimelineObjectView back
    [timelineObjectViewController.view.layer setZPosition:0];
}


-(void) timelineObjectWasDragged:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    if(timelineObjectViewController.view){
        [self setTimelineObjectViewsIntersectedByTimelineObjectViews:[NSArray arrayWithObject:timelineObjectViewController]];
    }
}


-(BOOL) timelineObjectWillStartDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    //brings the dragged view to front
    [timelineObjectViewController.view.layer setZPosition:10];
    return YES;
}

-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectViewController *)timelineObjectViewController{
    //brings the dragged view to front
    [timelineObjectViewController.view.layer setZPosition:10];
    return YES;
}

-(NSRect) timelineObjectWillResize:(VSTimelineObjectViewController *)timelineObjectViewController fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    return newFrame;
}

-(void) timelineObjectProxyWasResized:(VSTimelineObjectViewController *)timelineObjectViewController{
    [self setTimelineObjectViewsIntersectedByTimelineObjectViews:[NSArray arrayWithObject:timelineObjectViewController]];
}

-(void) timelineObjectDidStopResizing:(VSTimelineObjectViewController *)timelineObjectViewController{
    [self.view.undoManager beginUndoGrouping];
    
    
    double newStartTime = [self timeValueForPixelValue:timelineObjectViewController.view.frame.origin.x];
    double newDuration = [self timeValueForPixelValue:timelineObjectViewController.view.frame.size.width];
    
    //if the view has been moved, the start time of VSTimelineObjectProxy is updated
    if(newStartTime != timelineObjectViewController.timelineObjectProxy.startTime){
        [timelineObjectViewController.timelineObjectProxy changeStartTime:newStartTime andRegisterAtUndoManager:self.view.undoManager];
    }
    
    if(newDuration != timelineObjectViewController.timelineObjectProxy.duration){
        [timelineObjectViewController.timelineObjectProxy changeDuration:newDuration andRegisterAtUndoManager:self.view.undoManager];
    }
    
    [self applyIntersectionToTimelineObjects];
    
    [self.view.undoManager setActionName:NSLocalizedString(@"Resizing Object", @"Undo Action for resizine an object on the timeline")];
    [self.view.undoManager endUndoGrouping];
    
    //brings the dragge VSTimelineObjectView back
    [timelineObjectViewController.view.layer setZPosition:0];
}

-(NSPoint) timelineObjectWillBeDragged:(VSTimelineObjectViewController *)timelineObjectViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition{
    
    [self snapTimelineObjects:[NSArray arrayWithObject:timelineObjectViewController] movingToPositions:[NSArray arrayWithObject:[NSValue valueWithPoint:newPosition]]];
    return newPosition;
}
#pragma mark- Private Methods

-(void) snapTimelineObjects:(NSArray*) movingTimelineObjectViewControllers movingToPositions:(NSArray*) toPoints{
    NSMutableArray *newFrames = [[NSMutableArray alloc] init];
    
    NSRect unionRect;      
    int i = 0;
    
    for(VSTimelineObjectViewController *timelineObjectViewController in movingTimelineObjectViewControllers){
        NSRect frame = timelineObjectViewController.view.frame;
        frame.origin = [[toPoints objectAtIndex:i] pointValue];
        
        
        if(i != 0){
            unionRect = NSUnionRect(frame,unionRect);
        }
        else{
            unionRect = frame;
        }
        
        i++;
    }
    
    NSIndexSet *indexesOfOtherTimelineObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
            if ([movingTimelineObjectViewControllers containsObject:obj]) {
                return YES;
            }
        }
        return NO;
    }];
    

    
    DDLogInfo(@"Snapping Rect: %@",NSStringFromRect(unionRect));
}
    

/**
 * Returns a time value in milliseconds according to the current pixelTimeRatio
 * @param pixelValue Pixel value to be converted to a time value
 * @return The correpsonding time value in milliseconds corresponding to the current pixelTimeRatio
 */
-(double) timeValueForPixelValue:(NSInteger) pixelValue{
    return pixelValue * self.pixelTimeRatio;
}

#pragma mark VSTimelineObject Intersection

/**
 * Detects if any of the views the VSTimelineObjectControllers in the given NSArray are responsibel for are intersecting with any other VSTimelineObjectView on the Track.
 *
 * If an intersection is found, the VSTimelineObjectViewController of the intersected view is informed about it and the NSRect where the intersection happens is sent to it.
 * @param timelineObjectViewControllers NSArray of VSTimelineObjectViewControllers intersection will be detected for.
 */
-(void) setTimelineObjectViewsIntersectedByTimelineObjectViews:(NSArray *) timelineObjectViewControllers{
    
    for(VSTimelineObjectViewController *timelineObjectViewController in self.timelineObjectViewControllers){
        
        //intersections are detected only when the timelineObjectViewController is not in the given array of VSTimelineObjectViewController
        if(![timelineObjectViewControllers containsObject:timelineObjectViewController]){
            
            //Checks for every view in the given NSArray if an intersection can be found
            for(VSTimelineObjectViewController *draggedTimelineObjectViewController in timelineObjectViewControllers){
                
                NSRect intersectionRect =  NSIntersectionRect(draggedTimelineObjectViewController.view.frame, timelineObjectViewController.view.frame);
                
                if(!NSIsEmptyRect(intersectionRect)){
                    
                    intersectionRect.origin.x -= timelineObjectViewController.view.frame.origin.x;
                    
                    //When an intersection was newly found, it's set if the view intersects from left or from right
                    if(!timelineObjectViewController.intersected){
                        timelineObjectViewController.enteredLeft = intersectionRect.origin.x == 0 ? NO : YES;
                    }
                    else {
                        
                        //if the draggedView is over the middle of the timelineObjectViewController's view the intersection direction is changed
                        if(!timelineObjectViewController.enteredLeft){
                            if(NSMidX([timelineObjectViewController view].frame) < draggedTimelineObjectViewController.view.frame.origin.x){ 
                                timelineObjectViewController.enteredLeft = YES;
                                DDLogInfo(@"changed from right to left");
                            }
                            
                        }
                        else {
                            if(NSMidX([timelineObjectViewController view].frame)  > NSMaxX(draggedTimelineObjectViewController.view.frame)){
                                timelineObjectViewController.enteredLeft = NO;
                                DDLogInfo(@"changed from left to right");
                            }
                        }
                    }
                    
                    if(timelineObjectViewController.enteredLeft){
                        intersectionRect.size.width = timelineObjectViewController.view.frame.size.width - intersectionRect.origin.x;
                        
                    }
                    else {
                        NSInteger relativeDraggedFrameX = draggedTimelineObjectViewController.view.frame.origin.x -timelineObjectViewController.view.frame.origin.x;
                        intersectionRect.size.width = draggedTimelineObjectViewController.view.frame.size.width + relativeDraggedFrameX;
                        intersectionRect.origin.x = 0;
                    }
                    
                    
                    timelineObjectViewController.intersected = YES;
                    timelineObjectViewController.intersectionRect = intersectionRect;
                }
                else {
                    timelineObjectViewController.intersected = NO;
                }
            }
        }
    }
}

/**
 * Sets the "intersected"-Property of all VSTimelineObjectViewController's to NO
 */
-(void) resetIntersectedTimelineObjects{
    for(VSTimelineObjectViewController *timelineObjectViewController in  self.timelineObjectViewControllers){
        timelineObjectViewController.intersected = NO;
    }
}

/**
 * Detects the VSTimelineObjectViewControllers which are currenlty intersected.
 * @returns NSArray holding Track's VSTimelineObjectViewController where "intersected" is YES
 */
-(NSArray*) intersectedTimelineObjectViewController{
    NSIndexSet *indexSetOfIntersectedObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
            return ((VSTimelineObjectViewController*) obj).intersected;
        }
        return NO;
    } ];
    
    return [self.timelineObjectViewControllers objectsAtIndexes:indexSetOfIntersectedObjects];
}

/**
 * Applies the current intersection to the intersected VSTimelineObjectViewControllers to their VSTimelineObjectProxys.
 *
 * The intersectionRect of the VSTimelineObjectViewController is cut off and startTime and duration are updated.
 */
-(void) applyIntersectionToTimelineObjects{
    
    NSArray *interesectedTimelineObjectViewControllers= [self intersectedTimelineObjectViewController];
    
    for (VSTimelineObjectViewController *timelineObjectViewController in interesectedTimelineObjectViewControllers){
        
        //if the intersectionRect is wider as timelineObjectViewController.view.frame, the object is removed
        if(timelineObjectViewController.view.frame.size.width <= timelineObjectViewController.intersectionRect.size.width && timelineObjectViewController.view.frame.origin.x >= timelineObjectViewController.intersectionRect.origin.x){
            if([timelineObjectViewController.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
                [self.track removTimelineObject:(VSTimelineObject *) timelineObjectViewController.timelineObjectProxy andRegisterAtUndoManager:self.view.undoManager];
            }
        }
        else {
            
            //divides timelineObjectViewController.view.frame according to its intersectionRect
            NSRect slice;
            NSRect rem;
            NSDivideRect(timelineObjectViewController.view.frame, &slice, &rem, timelineObjectViewController.intersectionRect.size.width, NSMinXEdge);
            
            
            //depending of the intersection entered left or right, the object is cut differntly
            if(!timelineObjectViewController.enteredLeft){
                NSInteger newXPos = rem.origin.x - self.view.frame.origin.x;
                double newStartTime = newXPos * self.pixelTimeRatio;
                
                [timelineObjectViewController.timelineObjectProxy changeStartTime:newStartTime andRegisterAtUndoManager:self.view.undoManager];
                [timelineObjectViewController.timelineObjectProxy changeDuration:rem.size.width*self.pixelTimeRatio andRegisterAtUndoManager:self.view.undoManager];
            }
            else {
                double newDuration = rem.size.width*self.pixelTimeRatio;
                [timelineObjectViewController.timelineObjectProxy changeDuration:newDuration andRegisterAtUndoManager:self.view.undoManager];
            }
            
        }
        timelineObjectViewController.intersected = false;
    }
}

/**
 * Checks if the delegate of VSTrackViewController is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSTrackViewControllerDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

/**
 * Creates the frame for a given VSTimelineObjectProxy or VSTimelineObject according to the current pixelTimeRatio
 * @param proxy VSTimelineObjectProxy the frame will be created for.
 * @return The frame for a given VSTimelineObjectProxy or VSTimelineObject according to the current pixelTimeRatio
 */
-(NSRect) frameForTimelineObjectProxy:(VSTimelineObjectProxy*) proxy{
    NSRect frame = self.view.bounds;
    frame.origin.x = proxy.startTime / self.pixelTimeRatio;
    frame.size.width = proxy.duration / self.pixelTimeRatio;
    frame.size.height = self.view.frame.size.height;
    frame.origin.y = 0;
    
    
    return frame;
}


#pragma mark  Temporary Timeline Objects

/**
 * Adds a new VSTimelineObjectViewController to self.temporaryTimelineObjectViewControllers and inits it with the given trackView
 * @param aProxyObject VSTimelineObjectProxy the VSTimelineObjectViewController will be init with
 * @param aTrackView VSTrackView the view of VSTimelineObjectViewController is added to
 **/
-(void) setTemporaryTimelineObject:(VSTimelineObjectProxy*) aProxyObject toTrackView:(VSTrackView *) aTrackView{
    
    VSTimelineObjectViewController *newController = [[VSTimelineObjectViewController alloc] initWithDefaultNib];
    newController.timelineObjectProxy = aProxyObject;
    
    [[newController view] setFrame:[self frameForTimelineObjectProxy:aProxyObject]];
    
    [self.temporaryTimelineObjectViewControllers addObject:newController];
    
    newController.temporary = YES;
    
    [aTrackView addSubview:[newController view]];
    [newController.view setNeedsDisplay:YES];
    [aTrackView setNeedsDisplay:YES];
}


/**
 * Adds a new TimelineObject for the given VSProjectItemRepresentation to the given VSTrackView at the given position.
 * @param aProjectItem VSProjectItemRepresentation the VSTimelineObjectProxy will be based on
 * @param aPosition NSPoint where the VSTimelineObjectView is positioned
 * @param aTrackView VSTrackView the new TimelineObject will be added to
 * @return YES if it was created successfully, NO otherwise
 */
-(BOOL) addNewTemporaryTimelineObjectProxyBasedOn:(VSProjectItemRepresentation*) aProjectItem atPosition:(NSPoint) aPosition toTrack:(VSTrackView*)aTrackView{
    
    if([self delegateRespondsToSelector:@selector(trackViewController:createTimelineObjectProxyBasedOnProjectItemRepresentation:atPosition:)]){
        
        VSTimelineObjectProxy *newProxy = [self.delegate trackViewController:self createTimelineObjectProxyBasedOnProjectItemRepresentation:aProjectItem atPosition:aPosition];
        
        if (!newProxy) {
            return NO;
        }
        [self setTemporaryTimelineObject:newProxy toTrackView:aTrackView];
        
        return YES;
    }
    
    return NO;
}

/**
 * Removes all VSTimelineObjectVies stored in self.temporaryTimelineObjectViewControllers from the trackView and clears self.temporaryTimelineObjectViewControllers.
 * @return YES if the resetting was successfully, NO otherweise
 */
-(BOOL) resetTemporaryTimelineObjects{
    if([self.temporaryTimelineObjectViewControllers count] > 0){
        for (VSTimelineObjectViewController *ctrl in self.temporaryTimelineObjectViewControllers){
            [ctrl.view removeFromSuperview];
        }
        
        [self.temporaryTimelineObjectViewControllers removeAllObjects];
    }
    
    return NO;
}

#pragma mark Timeline Objects

/**
 * Creates a new VSTimelineObjectView sets it as subView of VSTrackViewerController's view and initis it with the given VSTimelineObject
 * @param aTimelineObject VSTimlineObject the newly added VSTimelineObjectView will represent.
 */

-(void) addNewTimelineObject:(VSTimelineObject*) aTimelineObject{
    VSTimelineObjectViewController* newController = [[VSTimelineObjectViewController alloc] initWithDefaultNib];
    
    newController.delegate = self;
    
    newController.timelineObjectProxy = aTimelineObject;
    
    [self.view addSubview:[newController view]];
    
    [[newController view] setFrame:[self frameForTimelineObjectProxy:aTimelineObject]];
    
    [self.timelineObjectViewControllers addObject:newController];
    
    [newController changePixelTimeRatio:self.pixelTimeRatio];
    
    [self.view setNeedsDisplay:YES];
}

/**
 * Removes aTimelineObject from the track.
 * @param aTimelineObject VSTimelineObject to be removed
 */
-(void) removeTimelineObject:(VSTimelineObject*) aTimelineObject{
    for(VSTimelineObjectViewController *ctrl in self.timelineObjectViewControllers){
        if (ctrl.timelineObjectProxy == aTimelineObject) {
            [ctrl.view removeFromSuperview];
            [self.timelineObjectViewControllers removeObject:ctrl];
            return;
        }
    }
}

@end
