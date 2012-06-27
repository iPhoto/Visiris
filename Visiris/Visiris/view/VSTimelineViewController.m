//
//  VSTimelineViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineViewController.h"

#import "VSTrackViewController.h"
#import "VSTimeline.h"
#import "VSPlayHead.h"
#import "VSTimelineView.h"
#import "VSTimelineObjectProxy.h"
#import "VSTimelineRulerView.h"
#import "VSTimelineObject.h"
#import "VSTrackLabelsViewController.h"
#import "VSTrackLabel.h"
#import "VSTrackHolderView.h"
#import "VSProjectItemRepresentation.h"

#import "VSCoreServices.h"

@interface VSTimelineViewController ()

/** NSArray holding the views representing the timeline's tracks */
@property (strong) NSMutableArray *trackViewControllers;

/** Displaying the timecode above the tracks */
@property (strong) NSRulerView *rulerView;

/** NSViewcController responsible for displaying the track labels in next to the timeline */
@property (strong) VSTrackLabelsViewController *trackLabelsViewController;

@property int trackOffset;

@end

// Default width of the track labels
#define TRACK_LABEL_WIDTH 30

@implementation VSTimelineViewController


@synthesize scrollView                  = _scvTrackHolder;
@synthesize trackHolder                 = _scrollViewHolder;
@synthesize rulerView                   = _rulerView;
@synthesize trackViewControllers        = _trackViewControllers;
@synthesize timeline                    = _timeline;
@synthesize pixelTimeRatio              = _pixelTimeRatio;
@synthesize trackLabelsViewController   = _trackLabelsViewController;
@synthesize trackOffset                 = _offsetTrack;


// Name of the nib that will be loaded when initWithDefaultNib is called 
static NSString* defaultNib = @"VSTimelineView";

#pragma mark- Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.trackViewControllers = [[NSMutableArray alloc] initWithCapacity:0];
        
    }
    
    return self;
}

-(id) initWithDefaultNibAccordingForTimeline:(VSTimeline*)timeline{
    if(self = [self initWithDefaultNib]){
        self.timeline = timeline;
        
        [self.timeline addObserver:self forKeyPath:@"duration" options:0 context:nil];
        [self.timeline.playHead addObserver:self forKeyPath:@"currentTimePosition" options:0 context:nil];
        
        if([self.view isKindOfClass:[VSTimelineView class]]){
            ((VSTimelineView*) self.view).delegate = self;
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
    
    [self initScrollView];
    
    [self initTimelineRuler];
    
    [self initTrackLabelsView];
    
    [self initPlayhead];
    
    [self updatePixelTimeRatio];
    
    [self initTracks];
    
    [self initObservers];   
}

/**
 * Registratres the class for observing
 */
-(void) initObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineObjectPropertIesDidTurnInactive:) name:VSTimelineObjectPropertiesDidTurnInactive object:nil];
}


/**
 * Sets the frame of the trackHolder and the AutoresizingMasks
 */
-(void) initScrollView{
    
    [self.trackHolder setFrame:NSMakeRect(0, 0, [self visibleTrackViewHolderWidth], self.scrollView.frame.size.height)];
    
    [self.trackHolder setAutoresizingMask:NSViewNotSizable];
    
    self.trackHolder.playheadMarkerDelegate = self;
    
}


-(void) initPlayhead{
    
}

/**
 * Creates a NSTrackView for every track the timeline holds
 */
-(void) initTracks{
    for(VSTrack* track in self.timeline.tracks){
        [self createTrack:track];
    }
}

/**
 * Initialises the timeline ruler which displays the timecode ruler.
 *
 * The timeline ruler is set as the horizontal ruler of scvTrackHolder
 */
-(void) initTimelineRuler{
    
    [self updateTimelineRulerMeasurement];
    
    self.rulerView = [self.scrollView horizontalRulerView];
    
    //sets the custom measurement unit VSTimelineRulerMeasurementUnit as measuerement unit of the timeline ruler
    [self.rulerView setMeasurementUnits:VSTimelineRulerMeasurementUnit];
}

/**
 * Inits the verticalRulerView displaying the labels for the tracks
 */
-(void) initTrackLabelsView{
    self.trackLabelsViewController = [[VSTrackLabelsViewController alloc] init];
    
    if ([self.trackLabelsViewController.view isKindOfClass:[NSRulerView class]]) {
        [self.scrollView setVerticalRulerView:(NSRulerView*) self.trackLabelsViewController.view];
        [((NSRulerView*) self.trackLabelsViewController.view) setOrientation:NSVerticalRuler];
        [self.scrollView setHasVerticalRuler:YES];
    }
}


#pragma mark - NSViewController


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //updates the length of the tracks and their timeline objects when the duration of the timeline has been changed
    if([keyPath isEqualToString:@"duration"]){
        
        //updates the frame of the scrollViews documentView
        NSRect newFrame = [self.trackHolder frame];
        newFrame.size.width = [[object valueForKey:keyPath] doubleValue] / self.pixelTimeRatio;
        [self.trackHolder setFrame:newFrame];
        
        //updates the pixelItemRatio
        [self updatePixelTimeRatio];
        
        
    }
    
    if([keyPath isEqualToString:@"currentTimePosition"]){
        if(!self.timeline.playHead.scrubbing){
            [self setPlayheadMarkerLocation];
        }
    }
}

#pragma mark - Event Handling

-(BOOL) acceptsFirstResponder{
    return YES;
}

-(void) keyDown:(NSEvent *)theEvent{
    if(theEvent){
        unichar keyCode = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
        if (keyCode == NSDeleteCharacter || keyCode == NSBackspaceCharacter){
            [self removeSelectedTimelineObjects];
        }
    }    
}


#pragma mark- VSTrackViewControlerDelegate implementation

-(void) didClickViewOfTrackViewController:(VSTrackViewController *)trackViewController{
    
    NSArray *selectedTimelineObjects = self.timeline.selectedTimelineObjects;
    
    [self.view.undoManager setActionName:NSLocalizedString(@"Change Selection", @"Undo Massage of unselecting TimelineObjects")];
    
    [self.view.undoManager beginUndoGrouping];
    
    for(VSTimelineObject *timelineObject in selectedTimelineObjects){
        [timelineObject setUnselectedAndRegisterUndo:self.view.undoManager];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotUnselected object:[self.timeline selectedTimelineObjects]];
    
    [self.view.undoManager endUndoGrouping];
}

#pragma mark Adding TimelineObjects

-(void) trackViewController:(VSTrackViewController *)trackViewController addTimelineObjectsBasedOnProjectItemRepresentation:(NSArray *)projectItemRepresentations atPositions:(NSArray *)positionArray withWidths:(NSArray *)widthArray{
    
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
            NSInteger width = [[widthArray objectAtIndex:i]intValue];
            
            
            double timePosition = [self getTimestampForPoint:position];
            NSInteger duration = [self getDurationForPixelWidth:width];
            
            //Sets the first object as the selected one wich's properites are shown
            if(i==0){
                objectToBeSelected = [self.timeline 
                                      addNewTimelineObjectBasedOnProjectItemRepresentation:projectItem 
                                      toTrack:trackViewController.track 
                                      positionedAtTime:timePosition 
                                      withDuration:duration 
                                      andRegisterUndoOperation:[self.view undoManager]
                                      ];
            }
            else {
                [self.timeline 
                 addNewTimelineObjectBasedOnProjectItemRepresentation:projectItem 
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

-(BOOL) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy willBeSelectedOnTrackViewController:(VSTrackViewController *)trackViewController exclusively:(BOOL)exclusiveSelection{
    
    return [self selectTimelineObjectProxy:timelineObjectProxy onTrack:trackViewController exclusively:exclusiveSelection];
}

-(void) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy wasSelectedOnTrackViewController:(VSTrackViewController *)trackViewController{
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotSelected object: [NSArray arrayWithObject:timelineObjectProxy]];
    }
}

-(void) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy wasUnselectedOnTrackViewController:(VSTrackViewController *)trackViewController{
    [[self.scrollView horizontalRulerView] setNeedsDisplay:YES];
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotUnselected object: [NSArray arrayWithObject:((VSTimelineObject*) timelineObjectProxy)]];
    }
}

#pragma mark Removing

-(void) timelineObjectProxies:(NSArray *)timelineObjectProxies wereRemovedFromTrack:(VSTrackViewController *)trackViewController{
    
    NSArray *selectedTimelineObjects = [timelineObjectProxies objectsAtIndexes:[timelineObjectProxies indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectProxy class]]){
            return ((VSTimelineObjectProxy*) obj).selected;
        }
        return NO;
    }]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotUnselected object:selectedTimelineObjects];
}

-(BOOL) removeTimelineObject:(VSTimelineObjectViewController *)timelineObjectViewController fromTrack:(VSTrackViewController *)track{
    [self removeTimlineObject:((VSTimelineObject*) timelineObjectViewController.timelineObjectProxy) fromTrack:track.track];
    
    return YES;
}


#pragma Moving TimlineObjects

-(NSPoint) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController WillBeDraggedOnTrack:(VSTrackViewController *)trackViewController fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition withSnappingDeltaX:(float)snappingDeltaX{
    
    float deltaX = newPosition.x - oldPosition.x;
    
    NSMutableArray *snappingDeltas = [[NSMutableArray alloc] init];
    
    
    //Calcluates the minimum Snapping-Distances of all selected objects on all tracks
    for(VSTrackViewController *tmpTrackViewController in self.trackViewControllers){
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
    for(VSTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController moveMoveableTimelineObjects:deltaX];
        }
    }
    
    return newPosition;
}

-(void) moveTimelineObjectTemporary:(VSTimelineObjectViewController *)timelineObject fromTrack:(VSTrackViewController *)fromTrack toTrackAtPosition:(NSPoint)position{
    
    int fromTrackArrayIndex = [self.trackViewControllers indexOfObject:fromTrack];
    int toTrackArrayIndex = fromTrackArrayIndex;
    int newTrackOffset = self.trackOffset; 
    
    NSPoint positionInView = [self.trackHolder convertPoint:position fromView:nil];
    
    int i = 0;
    
    for(VSTrackViewController *trackViewController in self.trackViewControllers){
        if(NSPointInRect(positionInView, trackViewController.view.frame)){
            toTrackArrayIndex = i;
            newTrackOffset = toTrackArrayIndex - fromTrackArrayIndex;
            break;
        }
        
        i++;
    }
    
    if(newTrackOffset != self.trackOffset){
        if(newTrackOffset >0){
            for(int i = self.trackViewControllers.count-1; i>=self.trackViewControllers.count-newTrackOffset; i--){
                if([[self.trackViewControllers objectAtIndex:i] isKindOfClass:[VSTrackViewController class]]){
                    if([((VSTrackViewController *)[self.trackViewControllers objectAtIndex:i]) selectedTimelineObjectViewControllers].count){
                        newTrackOffset--;
                    }
                }
            }
        }
        else if(newTrackOffset < 0){
            for(int i =0; i<newTrackOffset*(-1); i++){
                if([[self.trackViewControllers objectAtIndex:i] isKindOfClass:[VSTrackViewController class]]){
                    if([((VSTrackViewController *)[self.trackViewControllers objectAtIndex:i]) selectedTimelineObjectViewControllers].count){
                        newTrackOffset++;
                    }
                }
            }
        }
    }
    
    if(newTrackOffset != self.trackOffset){
        for(VSTrackViewController *trackViewController in self.trackViewControllers){
            [trackViewController resetTemporaryTimelineObjects];
            [trackViewController resetIntersections];
            if(fromTrackArrayIndex == toTrackArrayIndex)
                [trackViewController activateSelectedTimelineObjects];
        }
        
        if(fromTrackArrayIndex != toTrackArrayIndex){
            
            for(int i = 0; i<self.trackViewControllers.count; i++){
                VSTrackViewController *fromTrackViewController = (VSTrackViewController*) [self.trackViewControllers objectAtIndex:i]; 
                
                int newIndex = i + newTrackOffset;
                
                if(newIndex >= 0  && newIndex < self.trackViewControllers.count){
                    VSTrackViewController *toTrackViewController = (VSTrackViewController*) [self.trackViewControllers objectAtIndex:newIndex];
                    
                    [fromTrackViewController deactivateSelectedTimelineObjects];
                    
                    for (VSTimelineObjectViewController *timelineObjectViewController in [fromTrackViewController selectedTimelineObjectViewControllers]) {
                        
                        [toTrackViewController addTemporaryTimelineObject:timelineObjectViewController.timelineObjectProxy withFrame:timelineObjectViewController.view.frame];
                    }
                }
            }
        }
        
    }
    
    self.trackOffset = newTrackOffset;
}


-(void) timelineObject: timelineObjectViewController wasDraggedOnTrack:(VSTrackViewController *)trackViewController{
    for(VSTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController setTimelineObjectViewsIntersectedByMoveableTimelineObjects];
        }
    }
}

-(void) timelineObject:(VSTimelineObjectViewController *)timelineObjectViewController didStopDraggingOnTrack:(VSTrackViewController *)trackViewController{
    for(VSTrackViewController *tmpTrackViewController in self.trackViewControllers){
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController updateActiveMoveableTimelineObjectsAccordingToViewsFrame];
            [tmpTrackViewController applyIntersectionToTimelineObjects];
            [tmpTrackViewController removeInactiveSelectedTimelineObjectViewControllers];
            [tmpTrackViewController copyTemporaryTimelineObjectsToTrack];
            [tmpTrackViewController resetTemporaryTimelineObjects];
            [tmpTrackViewController unsetSelectedTimelineObjectsAsMoving];
            [tmpTrackViewController resetIntersections];
        }
    }
}

-(void) timelineObject: timelineObjectViewController willStartDraggingOnTrack:(VSTrackViewController *)trackViewController{
    
    self.trackOffset = 0;
    
    for(VSTrackViewController *tmpTrackViewController in self.trackViewControllers){    
        if(tmpTrackViewController != trackViewController){
            [tmpTrackViewController setSelectedTimelineObjectsAsMoving];
        }
    }
    
}

-(BOOL) splitTimelineObject:(VSTimelineObjectViewController *) timelineObjectViewController ofTrack:(VSTrackViewController *)trackViewController byRects:(NSArray *)splittingRects{
    
    VSTimelineObject *tmpTimelineObject = ((VSTimelineObject*) timelineObjectViewController.timelineObjectProxy);
    
    if(!tmpTimelineObject){
        return NO;
    }
    
    if(!splittingRects || !splittingRects.count){
        return NO;
    }
    
    NSRect viewsFrame = timelineObjectViewController.view.frame;
    
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
            NSRect leftFrame = viewsFrame;
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
        rightFrame.size.width = NSMaxX(viewsFrame) - rightFrame.origin.x;
        
        if(rightFrame.size.width > 0){
            [newFrames addObject:[NSValue valueWithRect:rightFrame]];
        }
        
        i++;
    }
    
    
    //if no newFrames were computed, the view is removed instead of splitted
    if(!newFrames.count){
        [self.timeline removeTimelineObject:tmpTimelineObject fromTrack:trackViewController.track];
    }
    else{
        int i = 0;
        for(NSValue *value in newFrames){
            
            NSRect frameRect = [value rectValue];
            double newStartTime = [self getTimestampForPoint:frameRect.origin];
            double newDuration = [self getDurationForPixelWidth:frameRect.size.width];   
            
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
                [self.timeline copyTimelineObject:tmpTimelineObject toTrack:trackViewController.track atPosition:newStartTime withDuration:newDuration andRegisterUndoOperation:self.trackLabelsViewController.view.undoManager];
            }
            i++;
        }
        return YES;
    }
    
    return NO;
}

-(void) copyTimelineObject:(VSTimelineObjectViewController *)timelineObjectViewController toTrack:(VSTrackViewController *)trackViewController{
    
    double startTime = [self getTimestampForPoint:timelineObjectViewController.view.frame.origin];
    double duration = [self getDurationForPixelWidth:timelineObjectViewController.view.frame.size.width]; 
    
    if([timelineObjectViewController.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        [self.timeline copyTimelineObject:(VSTimelineObject*) timelineObjectViewController.timelineObjectProxy toTrack:trackViewController.track atPosition:startTime withDuration:duration];
    }
    
    
}

#pragma mark- VSTimelineViewDelegate implementation

-(void) viewDidResizeFromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    
    if(oldFrame.size.width != newFrame.size.width){
        
        NSRect newDocumentFrame = self.trackHolder.frame;
        
        //updates the width according to how the width of the view has been resized
        newDocumentFrame.size.width += newFrame.size.width - oldFrame.size.width;
        [self.trackHolder setFrame:newDocumentFrame];
        [self updatePixelTimeRatio];
    }
}

-(void) didReceiveKeyDownEvent:(NSEvent *)theEvent{
    if(theEvent){
        unichar keyCode = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
        if (keyCode == NSDeleteCharacter || keyCode == NSBackspaceCharacter){
            [self removeSelectedTimelineObjects];
        }
    }
    
    
}

#pragma mark - VSPlayHeadRulerMarkerDelegate Implementation

-(BOOL) shouldMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    self.timeline.playHead.scrubbing = YES;
    return YES;
}

-(void) didMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView{
    self.timeline.playHead.scrubbing = NO;
}

-(CGFloat) willMovePlayHeadRulerMarker:(NSRulerMarker *)playheadMarker inContainingView:(NSView *)aView toLocation:(CGFloat)location{
    
    double newTimePosition = location * self.pixelTimeRatio;
    self.timeline.playHead.currentTimePosition = newTimePosition;
    
    return location;
}

#pragma mark - Private Methods

//TODO: Better way to update VSTimelineRulerMeasurementUnit
/**
 * Updates VSTimelineRulerMeasurementUnit according to the pixelTimeRatio
 */
-(void) updateTimelineRulerMeasurement{ 
    [NSRulerView registerUnitWithName:VSTimelineRulerMeasurementUnit abbreviation:VSTimelineRulerMeasurementAbreviation unitToPointsConversionFactor:1/self.pixelTimeRatio stepUpCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:10.0]] stepDownCycle:[NSArray arrayWithObject:[NSNumber numberWithFloat:0.5]]];
    
    [self.rulerView setMeasurementUnits:VSTimelineRulerMeasurementUnit];
}


/**
 * Creates a new TimelineObjectProxy according based on the vigen VSProjectItemRepresentation and positions it at the given positon*
 * @param trackViewController VSTrackViewController the newly the returned VSTimelineObjectProxy is created for
 * @param item VSProjectItemRepresentation the proxy will be based on
 * @param position NSPoint the proxy is places on the timeline
 * @return The newly create VSTimelineObjectProxy if the creation was successfully, nil otherwise
 */
-(VSTimelineObjectProxy*) trackViewController:(VSTrackViewController *)trackViewController createTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item atPosition:(NSPoint)position{
    
    
    
    double timePosition = [self getTimestampForPoint:position];
    
    return [self.timeline createNewTimelineObjectProxyBasedOnProjectItemRepresentation:item positionedAtTime:timePosition withDuration: item.duration];
}


/**
 * Sets the given VSTimelineObjectProxy selected an unselects the currenlty selected objects if the new seleciton is exclusive
 * @param timelineObjectProxy VSTimelineObjectProxy to be selected
 * @param trackViewController VSTrackViewController representing the track holding the timelineObjectProxy
 * @param exclusiveSelection IF yes the currently selected objects are set as unselected
 * @return YES if the selection was done successfully, NO otherwise
 */
-(BOOL) selectTimelineObjectProxy:(VSTimelineObjectProxy*) timelineObjectProxy onTrack:(VSTrackViewController*) trackViewController exclusively:(BOOL) exclusiveSelection{
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        [self.view.undoManager setActionName:NSLocalizedString(@"Change Selection", @"Undo Massage of unselecting TimelineObjects")];
        [self.view.undoManager beginUndoGrouping];
        
        if(exclusiveSelection){
            
            NSArray *selectedTimelineObjects = [self.timeline selectedTimelineObjects];
            
            for(VSTimelineObject *timelineObject in selectedTimelineObjects){
                [timelineObject setUnselectedAndRegisterUndo:self.view.undoManager];
            }
        }
        
        [self.timeline selectTimelineObject:((VSTimelineObject*) timelineObjectProxy) onTrack:trackViewController.track];
        
        if(timelineObjectProxy.selected){
            [((VSTimelineObject*) timelineObjectProxy) setSelectedAndRegisterUndo:self.view.undoManager];
            
        }
        
        [self.view.undoManager endUndoGrouping];
        
        return YES;
    }
    else {
        return NO;
    }
    
}

/**
 * Sets the plahead marker according to the playhead's currentposition on the timeline
 */
-(void) setPlayheadMarkerLocation{
    CGFloat newLocation = self.timeline.playHead.currentTimePosition / self.pixelTimeRatio;
    
    [self.trackHolder setPlayHeadMarkerToLocation:newLocation];
}

/**
 * Creates a new VSTrackView according to the given track.
 * @param track VSTrack the VSTrackView will be created for
 */
-(void) createTrack:(VSTrack*) track{
    
    VSTrackViewController* newTrackViewController = [[VSTrackViewController alloc]initWithDefaultNibAccordingToTrack:track];
    
    // The VSTimelineViewControlller acts as the delegate of the VSTrackViewController
    newTrackViewController.delegate = self;
    newTrackViewController.pixelTimeRatio = self.pixelTimeRatio;
    
    [self.trackHolder addSubview:[newTrackViewController view]];
    
    //Size and position of the track
    int width = [self visibleTrackViewHolderWidth];
    int yPosition = (VSTrackViewHeight+VSTrackViewMargin) * ([self.trackViewControllers count]);
    
    NSRect newFrame = NSMakeRect(self.scrollView.visibleRect.origin.x,yPosition,width,VSTrackViewHeight);
    
    [[newTrackViewController view] setFrame:newFrame];
    
    //set the autoresizing masks
    [[newTrackViewController view] setAutoresizingMask:NSViewWidthSizable];
    [[newTrackViewController view] setAutoresizesSubviews:NO];
    
    [self.trackViewControllers addObject:newTrackViewController];
    
    
    
    //Rescales the document view of the trackholder ScrollView
    int height = (VSTrackViewHeight+VSTrackViewMargin) * ([self.trackViewControllers  count]);
    [self.trackHolder setFrame:NSMakeRect([self.trackHolder frame].size.width, 0, self.trackHolder.frame.size.width,  height)];
    
    [self addNewTrackLabelForTrack:newTrackViewController];
}

/**
 * Creates a new label for the given Track and sends it to the trackLabelsViewController to display the label
 * @param aTrack VSTrackViewController the label is added for
 */
-(void) addNewTrackLabelForTrack:(VSTrackViewController*) aTrack{
    NSRect labelRect = NSMakeRect(0, aTrack.view.frame.origin.y, TRACK_LABEL_WIDTH, aTrack.view.frame.size.height);
    
    //NSLog(@"labelRect: %@",NSStringFromRect(labelRect));
    [self.trackLabelsViewController addTrackLabel:[[VSTrackLabel alloc] initWithName:aTrack.track.name forTrack:aTrack.track.trackID forFrame:labelRect]];
}

/**
 * Updates the ratio between the length of trackholder's width and the duration of the timeline
 */
-(void) updatePixelTimeRatio{
    double newRatio = self.timeline.duration / self.trackHolder.frame.size.width;
    
    if(newRatio != self.pixelTimeRatio){
        self.pixelTimeRatio = newRatio;
        [self pixelTimeRatioDidChange];
    }
}

/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange{
    [self updateTimelineRulerMeasurement];
    
    [self setPlayheadMarkerLocation];
    
    //tells all VSTrackViewControlls in the timeline, that the pixelItemRation has been changed
    for(VSTrackViewController *controller in self.trackViewControllers){
        [controller pixelTimeRatioDidChange:self.pixelTimeRatio];
        [controller.view setNeedsDisplay:YES];
    }
}

/**
 * The visible widht of the track holder is neccessary to calculation the pixelItemRation
 * @return The visble width of scvTrackHolder
 */
-(int) visibleTrackViewHolderWidth{
    return self.scrollView.documentVisibleRect.size.width - self.scrollView.verticalScroller.frame.size.width;
}

/**
 * Translates the given point to a timestamp according to the pixelTimeRation
 * @param point Point the timestamp will be created for
 * @return Timestamp for the given point
 */
-(double) getTimestampForPoint:(NSPoint) point{
    return point.x * self.pixelTimeRatio;
}

/**
 * Translats the given pixel width to time duration according to the pixelTimeRation
 * @param width Width the duration will translated for
 * @result Translated duration for the given width
 */
-(double) getDurationForPixelWidth:(NSInteger) width{
    return width * self.pixelTimeRatio;
}

/**
 * Called when VSTimelineObjectPropertiesDidTurnInactive Notification was received. Unselectes the currently selected timelineObjects.
 * @param notification NSNotifaction storing the information about which VSTimelineObjects were selected before the propertiesView turned inactive
 */
-(void) timelineObjectPropertIesDidTurnInactive:(NSNotification*) notification{
    [self.timeline unselectAllTimelineObjects];
}

-(VSTimelineObjectProxy*) createTimelineObjectProxyBasedOnProjectItemPresentation:(VSProjectItemRepresentation*) baseProjectItem atStarttime:(double) startTime withDuration:(double) duration{
    
    return [self.timeline createNewTimelineObjectProxyBasedOnProjectItemRepresentation:baseProjectItem positionedAtTime:startTime withDuration:duration];
}

#pragma mark Removing TimelineObjects

/**
 * Removes the currently selected TimelineObjects and registers the removal at the view's undoManager
 */
-(void) removeSelectedTimelineObjects{
    [self.view.undoManager beginUndoGrouping];
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
    [self.timeline removeTimelineObject:timelineObject fromTrack:track];
    [self.view.undoManager setActionName:NSLocalizedString(@"Remove Objects", @"Undo Action for removing TimelineObjects from the timeline")];
    [self.view.undoManager endUndoGrouping]; 
}

#pragma mark - Playhead


@end
