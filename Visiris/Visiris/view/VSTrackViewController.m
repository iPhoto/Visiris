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
@property NSMutableArray *timelineObjectViewControllers;

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
            
            self.timelineObjectViewControllers = [NSMutableArray arrayWithCapacity:0];
            
            self.projectItemController = [VSProjectItemController sharedManager];
            
            self.projectItemRepresentationController = [VSProjectItemRepresentationController sharedManager];
            
            ((VSTrackView*) self.view).controllerDelegate = self;
            
            self.temporaryTimelineObjectViewControllers = [[NSMutableArray alloc] init];
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


#pragma mark - Methods

-(void) pixelTimeRatioDidChange:(double)newRatio{
    if(self.pixelTimeRatio != newRatio){
        self.pixelTimeRatio = newRatio;
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


#pragma mark - VSTimelineObjectViewDelegate implementation

-(void)didSelectTimelineObjectView:(VSTimelineObjectView *)timelineObjectView{
    
}


#pragma mark- VSTrackViewDelegate implementation


-(BOOL) trackView:(VSTrackView *)trackView objectsHaveBeenDropped:(id<NSDraggingInfo>)draggingInfo atPosition:(NSPoint)position{
    
    BOOL result = NO;
    
    if(trackView){
        
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
        
        [self.view.undoManager beginUndoGrouping];
        if(droppedProjectItems.count > 0){
            
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
        }
        
    }
    
    [self changeIntersectedTimelineObjects];
    [self.view.undoManager endUndoGrouping];
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
        
        
        [self setTimelineObjectViewsIntersectedByDraggedTimelineObjectViews:self.temporaryTimelineObjectViewControllers];
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

-(BOOL) timelineObjectWillStartDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    [self.view sortSubviewsUsingFunction:bringViewInContextToFront context:(__bridge  void*)timelineObjectViewController.view];
    return YES;
}



static NSComparisonResult bringViewInContextToFront( id view1, id view2, void * context )
{    
    NSComparisonResult result = NSOrderedSame;
    if(view1 == (__bridge NSView*) context){
        result = NSOrderedDescending;
    }
    if(view2 == (__bridge NSView*) context){
        result = NSOrderedAscending;
    }
    printf("%ld",result);
    return result;
}

-(void) timelineObjectDidStopDragging:(VSTimelineObjectViewController *)timelineObjectViewController{
    
    
    double startTime = timelineObjectViewController.view.frame.origin.x * self.pixelTimeRatio;
    double duration = timelineObjectViewController.view.frame.size.width * self.pixelTimeRatio;
    
    
    [self.view.undoManager beginUndoGrouping];
    [self.view.undoManager setActionName:NSLocalizedString(@"Move Object", @"Undo action name for moving obejcts on timeline")];
    
    if(startTime != timelineObjectViewController.timelineObjectProxy.startTime){
        [timelineObjectViewController.timelineObjectProxy changeStartTime:startTime andRegisterAtUndoManager:self.view.undoManager];
    }
    
    if(duration != timelineObjectViewController.timelineObjectProxy.duration){
        [timelineObjectViewController.timelineObjectProxy changeDuration:duration andRegisterAtUndoManager:self.view.undoManager];
    }
    
    [self changeIntersectedTimelineObjects];
    
    [self.view.undoManager endUndoGrouping];
}



-(void) timelineObjectIsDragged:(VSTimelineObjectViewController *)timelineObjectViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition{
    if(timelineObjectViewController.view){
        
        NSRect newFrame = timelineObjectViewController.view.frame;
        newFrame.origin.x += newPosition.x - oldPosition.x;
        [timelineObjectViewController.view setFrame:newFrame];
        [timelineObjectViewController.view setNeedsDisplay:YES];
        
        [self setTimelineObjectViewsIntersectedByDraggedTimelineObjectViews:[NSArray arrayWithObject:timelineObjectViewController]];
        
    }
}

#pragma mark- Private Methods

-(void) setTimelineObjectViewsIntersectedByDraggedTimelineObjectViews:(NSArray *) timelineObjectViewControllers{
    for(VSTimelineObjectViewController *timelineObjectViewController in self.timelineObjectViewControllers){
        if(![timelineObjectViewControllers containsObject:timelineObjectViewController]){
            for(VSTimelineObjectViewController *draggedTimelineObjectViewController in timelineObjectViewControllers){
                NSRect intersectionRect =  NSIntersectionRect(draggedTimelineObjectViewController.view.frame, timelineObjectViewController.view.frame);
                
                if(!NSIsEmptyRect(intersectionRect)){
                    
                    intersectionRect.origin.x -= timelineObjectViewController.view.frame.origin.x;
                    
                    if(!timelineObjectViewController.intersected){
                        timelineObjectViewController.enteredLeft = intersectionRect.origin.x == 0 ? NO : YES;
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

-(void) changeIntersectedTimelineObjects{
    
    for (int i = self.timelineObjectViewControllers.count -1; i >=0 ; i--) {
        
        VSTimelineObjectViewController *timelineObjectViewController = [self.timelineObjectViewControllers objectAtIndex:i];
        if(timelineObjectViewController.intersected){
            if(timelineObjectViewController.view.frame.size.width <= timelineObjectViewController.intersectionRect.size.width && timelineObjectViewController.view.frame.origin.x >= timelineObjectViewController.intersectionRect.origin.x){
                if([timelineObjectViewController.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
                    [self.track removTimelineObject:(VSTimelineObject *) timelineObjectViewController.timelineObjectProxy andRegisterAtUndoManager:self.view.undoManager];
                }
            }
            else {
                NSRect slice;
                NSRect rem;
                
                NSDivideRect(timelineObjectViewController.view.frame, &slice, &rem, timelineObjectViewController.intersectionRect.size.width, NSMinXEdge);
                
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


#pragma mark - Temporary Timeline Objects

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

#pragma mark - Timeline Objects

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
