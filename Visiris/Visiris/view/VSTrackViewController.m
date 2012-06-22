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
#import "VSTimelineObjectViewIntersection.h"

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

// Size of the area objects can be snapped to other objects on the timelien
#define SNAPPING_AREA 20

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
        
        self.track = track;
        
        [self.track addObserver:self forKeyPath:@"timelineObjects" options:NSKeyValueObservingOptionPrior |NSKeyValueObservingOptionNew context:nil];
        
        self.projectItemController = [VSProjectItemController sharedManager];
        self.projectItemRepresentationController = [VSProjectItemRepresentationController sharedManager];
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
    self.timelineObjectViewControllers = [[NSMutableArray alloc] init];
    self.temporaryTimelineObjectViewControllers = [[NSMutableArray alloc] init];
    if([self.view isKindOfClass:[VSTrackView class]]){
        
        ((VSTrackView*) self.view).controllerDelegate = self;
    }
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

-(void) setSelectedTimelineObjectsAsMoving{
    NSArray *selectedObjects = [self selectedTimelineObjectViewControllers];
    
    if(selectedObjects.count == 0)
        return;
    
    for(VSTimelineObjectViewController *timelineObjectViewController in selectedObjects){
        timelineObjectViewController.moving = YES;
    }
}

-(void) unsetsetSelectedTimelineObjectsAsMoving{
    NSArray *selectedObjects = [self selectedTimelineObjectViewControllers];
    
    if(selectedObjects.count == 0)
        return;
    
    for(VSTimelineObjectViewController *timelineObjectViewController in selectedObjects){
        timelineObjectViewController.moving = NO;
    }
}

-(void) setStartTimeOfSelectedTimelineObjects{
    NSArray *selectedObjects = [self selectedTimelineObjectViewControllers];
    
    if(selectedObjects.count == 0)
        return;
    
    for(VSTimelineObjectViewController *timelineObjectViewController in self.timelineObjectViewControllers){
        double startTime = [self timeValueForPixelValue:timelineObjectViewController.view.frame.origin.x];
        
        //if the view has been moved, the start time of VSTimelineObjectProxy is updated
        if(startTime != timelineObjectViewController.timelineObjectProxy.startTime){
            [timelineObjectViewController.timelineObjectProxy changeStartTime:startTime andRegisterAtUndoManager:self.view.undoManager];
        }
    }
}

-(void) moveSelectedTimemlineObjects:(float) deltaX{
    if(deltaX != 0.0){
        
        NSArray *selectedTimelineObjects = [self selectedTimelineObjectViewControllers];
        
        for(VSTimelineObjectViewController *timelineObjectViewController in selectedTimelineObjects){
            NSPoint newPosition = timelineObjectViewController.view.frame.origin;
            newPosition.x += deltaX;
            [timelineObjectViewController.view setFrameOrigin:newPosition];
        }
        
    }
}


-(BOOL) computeSnappingXValueForSelectedTimelineObjectsMovedAccordingToDeltaX:(float)deltaX snappingDeltaX:(float *)snappingDeltaX{
    return [self computeSnappingXValueForTimelineObjects:[self selectedTimelineObjectViewControllers]  movedAccordingToDeltaX:deltaX snappingDelta:snappingDeltaX];
}

-(BOOL) computeSnappingXValueForTimelineObjects:(NSArray*) timelineObjectViewControllers movedAccordingToDeltaX:(float) deltaX snappingDelta:(float *)snappingDeltaX{
    
    BOOL returnValue = NO;
    
    *snappingDeltaX = 0;
    
    if(timelineObjectViewControllers.count){
        
        //The unionRect is created by combining the frames of the views of the timelineObjectViewControllers
        NSRect unionRect = ((VSTimelineObjectViewController*) [timelineObjectViewControllers objectAtIndex:0]).view.frame;
        unionRect.origin.x += deltaX;
        
        if(timelineObjectViewControllers.count >0){
            
            int i = 0;
            
            for(VSTimelineObjectViewController *timelineObjectViewController in timelineObjectViewControllers){
                NSRect frame = timelineObjectViewController.view.frame;
                NSPoint newOrigin = NSMakePoint(frame.origin.x + deltaX, frame.origin.y);
                frame.origin = newOrigin;
                
                
                if(i > 0){
                    unionRect = NSUnionRect(frame,unionRect);
                }
                else{
                    unionRect = frame;
                }
                
                i++;
            }
        }
        
        //snap to the zero Point of the timeline
        if(unionRect.origin.x < 0){
            *snappingDeltaX = unionRect.origin.x * (-1);
            returnValue = YES;
        }
        else {
            
            NSIndexSet *indexesOfOtherTimelineObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
                    if (![timelineObjectViewControllers containsObject:obj]) {
                        return YES;
                    }
                }
                return NO;
            }];
            
            
            NSArray *staticObjects = [self.timelineObjectViewControllers objectsAtIndexes:indexesOfOtherTimelineObjects];
            
            if(staticObjects && staticObjects.count){
                
                //creates the rects where unionRect is able to snap
                NSRect leftSnappingSourceRect = NSMakeRect(unionRect.origin.x - SNAPPING_AREA / 2.0, unionRect.origin.y,SNAPPING_AREA, unionRect.size.height);
                NSRect rightSnappingSourceRect = leftSnappingSourceRect;
                rightSnappingSourceRect.origin.x = NSMaxX(unionRect) - SNAPPING_AREA / 2.0f;    
                
                //iterates through all timelineObjectViewController in staticObjects and checks if the snappinRects of the unionRect are intersecting the snapping-rects of the objects in staticObjects
                for(VSTimelineObjectViewController *timelineObjectViewController in staticObjects){
                    
                     //creates the rect where the timelineObjectViewController is able to snap
                    NSRect targetSnappingRect = NSMakeRect(NSMaxX(timelineObjectViewController.view.frame)-SNAPPING_AREA / 2.0, timelineObjectViewController.view.frame.origin.y, SNAPPING_AREA, timelineObjectViewController.view.frame.size.height);
                    
                    if(NSIntersectsRect(leftSnappingSourceRect, targetSnappingRect)){
                        *snappingDeltaX = NSMaxX(timelineObjectViewController.view.frame) - unionRect.origin.x;
                        returnValue = YES;
                        break;
                    }
                    targetSnappingRect.origin.x = timelineObjectViewController.view.frame.origin.x - SNAPPING_AREA / 2.0f;
                    if(NSIntersectsRect(rightSnappingSourceRect, targetSnappingRect)){
                        *snappingDeltaX = timelineObjectViewController.view.frame.origin.x - NSMaxX(unionRect);
                        returnValue = YES;
                        break;
                    }
                    
                }
                
            }
        }
        
    } 
    return returnValue;
}

-(void) applyIntersectionToTimelineObjects{
    
    NSArray *intersectedTimelineObjectViewControllers = [self intersectedTimelineObjectViewControllers];
    
    for(VSTimelineObjectViewController *intersectedTimelineObjectViewController in intersectedTimelineObjectViewControllers){
        
        if(intersectedTimelineObjectViewController.intersectedTimelineObjectViews.count){
            
            NSArray *intersections = [intersectedTimelineObjectViewController.intersectedTimelineObjectViews allValues];
            
            NSMutableArray *intersectionRects = [[NSMutableArray alloc] init];
            
            for(VSTimelineObjectViewIntersection *intersection in intersections){
                [intersectionRects addObject: [NSValue valueWithRect:intersection.intersectedTimelineObjectView.view.frame]];
            }
            
            if([self delegateRespondsToSelector:@selector(splitTimelineObject:ofTrack:byRects:)]){
                [self.delegate splitTimelineObject:intersectedTimelineObjectViewController ofTrack:self byRects:intersectionRects];
            }
            
        }
    }
}


-(void) setTimelineObjectViewsIntersectedBySelectedTimelineObjects{    
    [self setTimelineObjectViews:[self unselectedTimelineObjectViewControllers] IntersectedByTimelineObjectViews:[self selectedTimelineObjectViewControllers]];
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


#pragma mark - VSTrackViewDelegate Implmentation

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
            
            [self setTimelineObjectViews:self.timelineObjectViewControllers IntersectedByTimelineObjectViews:self.temporaryTimelineObjectViewControllers];
            
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

-(void) trackView:(VSTrackView *)trackView draggedObjects:(id<NSDraggingInfo>)draggingInfo movedFromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition{
    
    if(!trackView)
        return;
    
    //sets the positions for all views of VSTimelineObjectViewControllers stored in self.temporaryTimelineObjectViewControllers 
    if([self.temporaryTimelineObjectViewControllers count] > 0){
        
        VSTimelineObjectViewController *firstTimelineObjectViewController = (VSTimelineObjectViewController*) [self.temporaryTimelineObjectViewControllers objectAtIndex:0];
        
        if(firstTimelineObjectViewController){
            
            float deltaX = newPosition.x - firstTimelineObjectViewController.view.frame.origin.x;
            float snappingDeltaX =0;
            [self computeSnappingXValueForTimelineObjects:self.temporaryTimelineObjectViewControllers movedAccordingToDeltaX:deltaX snappingDelta:&snappingDeltaX];
            
            //if more than one VSTimelineObjectViewControllers is stored in self.temporaryTimelineObjectViewControllers their views are positioned next to each other
            for(VSTimelineObjectViewController *timelineObjectViewController in self.temporaryTimelineObjectViewControllers){
                
                //sets the frame for timelineObjectViewController's view
                NSRect newFrame =  timelineObjectViewController.view.frame;
                newFrame.origin.x += deltaX + snappingDeltaX;
                
                
                
                [timelineObjectViewController.view setFrame:newFrame];
            }
            
            //Checks if any of the existing timeline objects intersected by any of the views stored in temporaryTimelineObjectViewControllers
            [self setTimelineObjectViews:self.timelineObjectViewControllers IntersectedByTimelineObjectViews:self.temporaryTimelineObjectViewControllers];
            
        }
        
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
    
    
    int i = 0;
    int currentTotalWidth = 0;
    
    //for each VSProjectItemRepresentation found and stored in draggedProjectItems a new VSTimelineObjectProxy is created and added to self.temporaryTimelineObjectViewControllers 
    for(VSProjectItemRepresentation *item in draggedProjectItems){
        VSTimelineObjectViewController *timelineObjectViewController = [self addNewTemporaryTimelineObjectProxyBasedOn:item atPosition:position toTrack:trackView temporaryID:i];
        
        
        //sets the frame for timelineObjectViewController's view
        NSRect newFrame =  timelineObjectViewController.view.frame;
        newFrame.origin.x = position.x + currentTotalWidth;
        newFrame.size.width = timelineObjectViewController.timelineObjectProxy.duration / self.pixelTimeRatio;
        currentTotalWidth += newFrame.size.width;
        
        
        
        [timelineObjectViewController.view setFrame:newFrame];
        
        i++;
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
    
    //removes the temporary timelineObjects of the trackView
    [self resetIntersections];
    return [self resetTemporaryTimelineObjects];
}

-(void) didClicktrackView:(VSTrackView *)trackView{
    if([self delegateRespondsToSelector:@selector(didClickViewOfTrackViewController:)]){
        [self.delegate didClickViewOfTrackViewController:self];
    }
}

#pragma mark- VSTimelineObjectViewControllerDelegate implementation

#pragma mark Selecting

-(BOOL)timelineObjectProxyWillBeSelected:(VSTimelineObjectProxy *)timelineObjectProxy exclusively:(BOOL)exclusiveSelection{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxy:willBeSelectedOnTrackViewController:exclusively:)]){
        return [self.delegate timelineObjectProxy:timelineObjectProxy willBeSelectedOnTrackViewController:self exclusively:exclusiveSelection];
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

#pragma mark Resizing

-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectViewController *)timelineObjectViewController{
    return YES;
}

-(NSRect) timelineObjectWillResize:(VSTimelineObjectViewController *)timelineObjectViewController fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    return newFrame;
}

-(void) timelineObjectProxyWasResized:(VSTimelineObjectViewController *)timelineObjectViewController{
    NSMutableArray *otherTimelineObjectViewControllers = [NSMutableArray arrayWithArray:self.timelineObjectViewControllers];
    
    [otherTimelineObjectViewControllers removeObject:timelineObjectViewController];
    
    [self setTimelineObjectViews:otherTimelineObjectViewControllers IntersectedByTimelineObjectViews:[NSArray arrayWithObject:timelineObjectViewController]];
}

-(void) timelineObjectDidStopResizing:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    NSMutableArray *otherTimelineObjectViewControllers = [NSMutableArray arrayWithArray:self.timelineObjectViewControllers];
    
    [otherTimelineObjectViewControllers removeObject:timelineObjectViewController];
    
    [self setTimelineObjectViews:otherTimelineObjectViewControllers IntersectedByTimelineObjectViews:[NSArray arrayWithObject:timelineObjectViewController]];
    
    
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
}

#pragma mark Dragging (Moving)

-(NSPoint) timelineObjectWillBeDragged:(VSTimelineObjectViewController *)timelineObjectViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition{
    
    float deltaXPosition = newPosition.x - oldPosition.x;
    float snappingDeltaX;
    [self computeSnappingXValueForSelectedTimelineObjectsMovedAccordingToDeltaX:deltaXPosition snappingDeltaX:&snappingDeltaX];
    
    
    if([self delegateRespondsToSelector:@selector(timelineObject:WillBeDraggedOnTrack:fromPosition:toPosition: withSnappingDeltaX:)]){
        newPosition = [self.delegate timelineObject:timelineObjectViewController WillBeDraggedOnTrack:self fromPosition:oldPosition toPosition:newPosition withSnappingDeltaX:snappingDeltaX];
    }
    else{
        newPosition.x += snappingDeltaX;
    }
    
    deltaXPosition = newPosition.x - oldPosition.x;
    
    [self moveSelectedTimemlineObjects:deltaXPosition];
    
    return newPosition;
    
}

-(void) timelineObjectDidStopDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    [self setTimelineObjectViewsIntersectedBySelectedTimelineObjects];
    
    if([self delegateRespondsToSelector:@selector(timelineObject:didStopDraggingOnTrack:)]){
        [self.delegate timelineObject:timelineObjectViewController didStopDraggingOnTrack:self];
    }
    
    [self unsetsetSelectedTimelineObjectsAsMoving];
    
    [self.view.undoManager beginUndoGrouping];
    
    [self setStartTimeOfSelectedTimelineObjects];
    
    //applys the interscetions
    
    [self applyIntersectionToTimelineObjects];
    
    [self.view.undoManager setActionName:NSLocalizedString(@"Move Object", @"Undo action name for moving obejcts on timeline")];
    [self.view.undoManager endUndoGrouping];
    
}


-(void) timelineObjectWasDragged:(VSTimelineObjectViewController *)timelineObjectViewController{
    if([self delegateRespondsToSelector:@selector(timelineObject:wasDraggedOnTrack:)]){
        [self.delegate timelineObject:timelineObjectViewController wasDraggedOnTrack:self];
    }
    if(timelineObjectViewController.view){
        [self setTimelineObjectViewsIntersectedBySelectedTimelineObjects];
    }
}


-(BOOL) timelineObjectWillStartDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    if([self delegateRespondsToSelector:@selector(timelineObject:willStartDraggingOnTrack:)]){
        [self.delegate timelineObject:timelineObjectViewController willStartDraggingOnTrack:self];
    }
    
    [self setSelectedTimelineObjectsAsMoving];
    
    return YES;
}

#pragma mark - pleas move me to mehtods




#pragma mark- Private Methods

-(NSArray*) intersectedTimelineObjectViewControllers{
    NSIndexSet *indexSetOfSelectedTimelineObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
            if(((VSTimelineObjectViewController*) obj).intersectedTimelineObjectViews.count){
                return YES;
            }
        }
        return NO;
    }];
    
    return [self.timelineObjectViewControllers objectsAtIndexes:indexSetOfSelectedTimelineObjects];
}

-(NSArray*) selectedTimelineObjectViewControllers{
    NSIndexSet *indexSetOfSelectedTimelineObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
            if(((VSTimelineObjectViewController*) obj).timelineObjectProxy.selected){
                return YES;
            }
        }
        return NO;
    }];
    
    return [self.timelineObjectViewControllers objectsAtIndexes:indexSetOfSelectedTimelineObjects];
}

-(NSArray*) unselectedTimelineObjectViewControllers{
    NSIndexSet *indexSetOfSelectedTimelineObjects = [self.timelineObjectViewControllers indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectViewController class]]){
            if(!((VSTimelineObjectViewController*) obj).timelineObjectProxy.selected){
                return YES;
            }
        }
        return NO;
    }];
    
    return [self.timelineObjectViewControllers objectsAtIndexes:indexSetOfSelectedTimelineObjects];
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
 * Detects if any of the views in intersectingTimelineObjectViewControllers intersects any of one in timelineObjectViewControllers.
 *
 * If an intersection is found, the VSTimelineObjectViewController of the intersected view is informed about it and the NSRect where the intersection happens is sent to it.
 * @param timelineObjectViewControllers NSArray of VSTimelineObjectViewControllers intersection will be detected for.
 * @param intersectingTimelineObjectViewControllers NSArray of VSTimelineObjectViewControllers which will be checked for intersecting any of VSTimelineObjectViewControllers in timelineObjectViewControllers.
 */
-(void) setTimelineObjectViews:(NSArray*) timelineObjectViewControllers IntersectedByTimelineObjectViews:(NSArray*) intersectingTimelineObjectViewControllers{
    
    for(VSTimelineObjectViewController *intersectingTimelineObjectViewController in intersectingTimelineObjectViewControllers){
        //Checks for every view in the given NSArray if an intersection can be found
        for(VSTimelineObjectViewController *timelineObjectViewController in timelineObjectViewControllers){
            
            NSRect intersectionRect =  NSIntersectionRect(timelineObjectViewController.view.frame, intersectingTimelineObjectViewController.view.frame);
            
            if(!NSIsEmptyRect(intersectionRect)){
                
                intersectionRect.origin.x -= timelineObjectViewController.view.frame.origin.x;
                
                [timelineObjectViewController intersectsTimelineObjectView:intersectingTimelineObjectViewController intersects:intersectionRect];
            }
            else{
                [timelineObjectViewController removeIntersectionWith:intersectingTimelineObjectViewController];
            }
        }
    }
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
-(VSTimelineObjectViewController*) setTemporaryTimelineObject:(VSTimelineObjectProxy*) aProxyObject toTrackView:(VSTrackView *) aTrackView{
    
    VSTimelineObjectViewController *newController = [[VSTimelineObjectViewController alloc] initWithDefaultNib];
    newController.timelineObjectProxy = aProxyObject;
    
    [[newController view] setFrame:[self frameForTimelineObjectProxy:aProxyObject]];
    
    [self.temporaryTimelineObjectViewControllers addObject:newController];
    
    newController.temporary = YES;
    
    [aTrackView addSubview:[newController view]];
    [newController.view setNeedsDisplay:YES];
    [aTrackView setNeedsDisplay:YES];
    
    return newController;
}


/**
 * Adds a new TimelineObject for the given VSProjectItemRepresentation to the given VSTrackView at the given position.
 * @param aProjectItem VSProjectItemRepresentation the VSTimelineObjectProxy will be based on
 * @param aPosition NSPoint where the VSTimelineObjectView is positioned
 * @param aTrackView VSTrackView the new TimelineObject will be added to
 * @param temporaryID Temporarily set ID for the temporary timeline object
 * @return YES if it was created successfully, NO otherwise
 */
-(VSTimelineObjectViewController*) addNewTemporaryTimelineObjectProxyBasedOn:(VSProjectItemRepresentation*) aProjectItem atPosition:(NSPoint) aPosition toTrack:(VSTrackView*)aTrackView temporaryID:(NSInteger) temporaryID{
    
    if([self delegateRespondsToSelector:@selector(trackViewController:createTimelineObjectProxyBasedOnProjectItemRepresentation:atPosition:)]){
        
        VSTimelineObjectProxy *newProxy = [self.delegate trackViewController:self createTimelineObjectProxyBasedOnProjectItemRepresentation:aProjectItem atPosition:aPosition];
        
        if (!newProxy) {
            return nil;
        }
        
        newProxy.timelineObjectID = temporaryID;
        
        return [self setTemporaryTimelineObject:newProxy toTrackView:aTrackView];
        
    }
    
    return nil;
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

/**
 * Removes the intersections of all timeline objects
 */
-(void) resetIntersections{
    NSArray *intersectedTimelineObjectViewControllers = [self intersectedTimelineObjectViewControllers];
    
    for(VSTimelineObjectViewController *intersectedTimelineObjectViewController in intersectedTimelineObjectViewControllers){
        [intersectedTimelineObjectViewController.intersectedTimelineObjectViews removeAllObjects];   
    }
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

@end
