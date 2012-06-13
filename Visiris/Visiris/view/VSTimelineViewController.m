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
#import "VSTimelineView.h"
#import "VSTimelineObjectProxy.h"
#import "VSTimelineRulerView.h"
#import "VSTimelineObject.h"
#import "VSPlayheadViewController.h"
#import "VSTrackLabelsViewController.h"
#import "VSTrackLabel.h"

#import "VSCoreServices.h"

@interface VSTimelineViewController ()

@property (strong) NSMutableArray *trackViewControllers;

@property (strong) VSPlayheadViewController *playheadViewController;

/** Displaying the timecode above the tracks */
@property (strong) NSRulerView *rulerView;

@property (strong) VSTrackLabelsViewController *trackLabelsViewController;



/** DocumentView of scvTrackHolder*/
@property NSView *tracksHolderdocumentView;

@end


#define TRACK_LABEL_WIDTH 30
#define PLAYHEAD_WIDTH 30


@implementation VSTimelineViewController


@synthesize scvTrackHolder              = _scvTrackHolder;
@synthesize tracksHolderdocumentView    = _tracksHolderdocumentView;
@synthesize rulerView                   = _rulerView;
@synthesize trackViewControllers        = _trackViewControllers;
@synthesize timeline                    = _timeline;
@synthesize pixelTimeRatio              = _pixelTimeRatio;
@synthesize playheadViewController      = _playheadViewController;
@synthesize trackLabelsViewController   = _trackLabelsViewController;


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
    [self.view setWantsLayer:YES];
    
    
    [self initScrollView];
    
    
    
    [self initTracks];
    //    [self updatePixelTimeRatio];
    
    [self initTimelineRuler];
    [self initTrackLabelsView];
    [self initPlayhead];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineObjectPropertIesDidTurnInactive:) name:VSTimelineObjectPropertiesDidTurnInactive object:nil];
}

-(void) initScrollView{
    
    [self.scvTrackHolder setHorizontalRulerView:self.rulerView];
    
    [self.scvTrackHolder setHasHorizontalRuler:YES];
    [self.scvTrackHolder setHasVerticalRuler:YES];
    [self.scvTrackHolder setRulersVisible:YES];
    
    [self.tracksHolderdocumentView setFrame:NSMakeRect(0, 0, [self visibleTrackViewHolderWidth], self.scvTrackHolder.frame.size.height)];
    
    [self.tracksHolderdocumentView setAutoresizingMask:NSViewNotSizable];
    [self.scvTrackHolder.documentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentViewsBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:nil];
    
}

-(void) documentViewsBoundsDidChange:(NSNotification*) notification{
    [self.scvTrackHolder.horizontalRulerView setNeedsDisplay:YES];
    [self.scvTrackHolder.verticalRulerView setNeedsDisplay:YES];
}

-(void) initPlayhead{
    
    self.playheadViewController = [[VSPlayheadViewController alloc] initWithPlayHead:self.timeline.playHead];
    
    [self.view addSubview:self.playheadViewController.view positioned:NSWindowAbove relativeTo:self.scvTrackHolder];
    
    
    [self updatePlayhead];
    
    [self.playheadViewController.view setWantsLayer:YES];
    [self.playheadViewController.view.layer setZPosition:10];
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
    
    self.rulerView = [self.scvTrackHolder horizontalRulerView];
    
    //sets the custom measurement unit VSTimelineRulerMeasurementUnit as measuerement unit of the timeline ruler
    [self.rulerView setMeasurementUnits:VSTimelineRulerMeasurementUnit];
    
    
    
}


-(void) initTrackLabelsView{
    self.trackLabelsViewController = [[VSTrackLabelsViewController alloc] init];
    
    if ([self.trackLabelsViewController.view isKindOfClass:[NSRulerView class]]) {
        [self.scvTrackHolder setVerticalRulerView:(NSRulerView*) self.trackLabelsViewController.view];
        [((NSRulerView*) self.trackLabelsViewController.view) setOrientation:NSVerticalRuler];
        [self.scvTrackHolder setHasVerticalRuler:YES];
    }
}


#pragma mark - NSViewController


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //updates the length of the tracks and their timeline objects when the duration of the timeline has been changed
    if([keyPath isEqualToString:@"duration"]){
        
        //updates the frame of the scrollViews documentView
        NSRect newFrame = [self.tracksHolderdocumentView frame];
        newFrame.size.width = [[object valueForKey:keyPath] doubleValue] / self.pixelTimeRatio;
        [self.tracksHolderdocumentView setFrame:newFrame];
        
        //updates the pixelItemRatio
        [self updatePixelTimeRatio];
        
        
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

-(void) trackViewController:(VSTrackViewController *)trackViewController addTimelineObjectsBasedOnProjectItemRepresentation:(NSArray *)projectItemRepresentations atPositions:(NSArray *)positionArray withWidths:(NSArray *)widthArray{
    
    if ((projectItemRepresentations) && (projectItemRepresentations.count >0)) {
        
        int i = 0;
        
        [[self.view undoManager] setActionName:projectItemRepresentations.count > 1 ? 
         NSLocalizedString(@"Adding Objects", @"Undo Action for adding objects to the timeline") : 
         NSLocalizedString(@"Adding Object", @"Undo Action for adding one object to the timeline")
         ];
        
        [[self.view undoManager] beginUndoGrouping];
        
        VSTimelineObject *objectToBeSelected;
        
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
        
        [self selectTimelineObjectProxy:objectToBeSelected onTrack:trackViewController];
        
        [[self.view undoManager] endUndoGrouping];
    }
    
    [self.view.window makeFirstResponder:self.view];
}

-(VSTimelineObjectProxy*) trackViewController:(VSTrackViewController *)trackViewController createTimelineObjectProxyBasedOnProjectItemRepresentation:(VSProjectItemRepresentation *)item atPosition:(NSPoint)position{
    
    double timePosition = [self getTimestampForPoint:position];
    
    return [self.timeline createNewTimelineObjectProxyBasedOnProjectItemRepresentation:item positionedAtTime:timePosition];
}

-(BOOL) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy willBeSelectedOnTrackViewController:(VSTrackViewController *)trackViewController{
    return [self selectTimelineObjectProxy:timelineObjectProxy onTrack:trackViewController];
}

-(void) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy wasSelectedOnTrackViewController:(VSTrackViewController *)trackViewController{
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotSelected object: [NSArray arrayWithObject:timelineObjectProxy]];
    }
}

-(void) timelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy wasUnselectedOnTrackViewController:(VSTrackViewController *)trackViewController{
    [[self.scvTrackHolder horizontalRulerView] setNeedsDisplay:YES];
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotUnselected object: [NSArray arrayWithObject:((VSTimelineObject*) timelineObjectProxy)]];
    }
}

-(BOOL) selectTimelineObjectProxy:(VSTimelineObjectProxy*) timelineObjectProxy onTrack:(VSTrackViewController*) trackViewController{
    if([timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        
        [self.view.undoManager setActionName:NSLocalizedString(@"Change Selection", @"Undo Massage of unselecting TimelineObjects")];
        [self.view.undoManager beginUndoGrouping];
        
        NSArray *selectedTimelineObjects = [self.timeline selectedTimelineObjects];
        
        for(VSTimelineObject *timelineObject in selectedTimelineObjects){
            [timelineObject setUnselectedAndRegisterUndo:self.view.undoManager];
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
-(void) timelineObjectProxies:(NSArray *)timelineObjectProxies wereRemovedFromTrack:(VSTrackViewController *)trackViewController{
    
    NSArray *selectedTimelineObjects = [timelineObjectProxies objectsAtIndexes:[timelineObjectProxies indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSTimelineObjectProxy class]]){
            return ((VSTimelineObjectProxy*) obj).selected;
        }
        return NO;
    }]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectsGotUnselected object:selectedTimelineObjects];
}

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

#pragma mark- VSTimelineViewDelegate implementation

-(void) viewDidResizeFromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame{
    
    [self updatePlayhead];
    
    if(oldFrame.size.width != newFrame.size.width){
        
        NSRect newDocumentFrame = self.tracksHolderdocumentView.frame;
        
        //updates the width according to how the width of the view has been resized
        newDocumentFrame.size.width += newFrame.size.width - oldFrame.size.width;
        [self.tracksHolderdocumentView setFrame:newDocumentFrame];
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
 * Creates a new VSTrackView according to the given track.
 * @param track VSTrack the VSTrackView will be created for
 */
-(void) createTrack:(VSTrack*) track{
    
    VSTrackViewController* newTrackViewController = [[VSTrackViewController alloc]initWithDefaultNibAccordingToTrack:track];
    
    // The VSTimelineViewControlller acts as the delegate of the VSTrackViewController
    newTrackViewController.delegate = self;
    newTrackViewController.pixelTimeRatio = self.pixelTimeRatio;
    
    [self.tracksHolderdocumentView addSubview:[newTrackViewController view]];
    
    //Size and position of the track
    int width = [self visibleTrackViewHolderWidth];
    int yPosition = (VSTrackViewHeight+VSTrackViewMargin) * ([self.tracksHolderdocumentView.subviews count] -1);
    
    NSRect newFrame = NSMakeRect(self.scvTrackHolder.visibleRect.origin.x,yPosition,width,VSTrackViewHeight);
    
    [[newTrackViewController view] setFrame:newFrame];
    
    //set the autoresizing masks
    [[newTrackViewController view] setAutoresizingMask:NSViewWidthSizable];
    [[newTrackViewController view] setAutoresizesSubviews:NO];
    
    [self.trackViewControllers addObject:newTrackViewController];
    
    [newTrackViewController.view setNeedsDisplay:YES];
    
    //Rescales the document view of the trackholder ScrollView
    int height = (VSTrackViewHeight+VSTrackViewMargin) * ([self.tracksHolderdocumentView.subviews count]);
    [self.tracksHolderdocumentView setFrame:NSMakeRect([self.tracksHolderdocumentView frame].size.width, 0, self.tracksHolderdocumentView.frame.size.width,  height)];
    
    [self addNewTrackLabelForTrack:newTrackViewController];
}

-(void) addNewTrackLabelForTrack:(VSTrackViewController*) aTrack{
    NSRect labelRect = NSMakeRect(self.scvTrackHolder.verticalRulerView.frame.size.height - aTrack.view.frame.origin.y, aTrack.view.frame.origin.y, TRACK_LABEL_WIDTH, aTrack.view.frame.size.height);
    [self.trackLabelsViewController addTrackLabel:[[VSTrackLabel alloc] initWithName:aTrack.track.name forTrack:aTrack.track.trackID forFrame:labelRect]];
}

/**
 * Updates the ratio between the length of trackholder's width and the duration of the timeline
 */
-(void) updatePixelTimeRatio{
    double newRatio = self.timeline.duration / self.tracksHolderdocumentView.frame.size.width;
    
    if(newRatio != self.pixelTimeRatio){
        self.pixelTimeRatio = newRatio;
        [self pixelTimeRatioDidChange];
        [self.playheadViewController changePixelItemRatio:self.pixelTimeRatio];
    }
}

/**
 * Called when ratio between the length of trackholder's width and the duration of the timeline.
 */
-(void) pixelTimeRatioDidChange{
    [self updateTimelineRulerMeasurement];
    
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
    return self.scvTrackHolder.documentVisibleRect.size.width - self.scvTrackHolder.verticalScroller.frame.size.width;
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

/**
 * Removes the currently selected TimelineObjects and registers the removal at the view's undoManager
 */
-(void) removeSelectedTimelineObjects{
    [self.view.undoManager beginUndoGrouping];
    [self.timeline removeSelectedTimelineObjectsAndRegisterAtUndoManager:self.view.undoManager];
    [self.view.undoManager setActionName:NSLocalizedString(@"Remove Objects", @"Undo Action for removing TimelineObjects from the timeline")];
    [self.view.undoManager endUndoGrouping];
}

#pragma mark - Playhead
 
-(void) updatePlayhead{
    NSRect newFrame = self.playheadViewController.view.frame;
    
    newFrame.size.width = PLAYHEAD_WIDTH;
    newFrame.size.height = self.scvTrackHolder.documentVisibleRect.size.height + self.rulerView.frame.size.height;    
    newFrame.origin.y = self.view.frame.size.height - newFrame.size.height;
    newFrame.origin.x = newFrame.origin.x < self.scvTrackHolder.verticalRulerView.frame.size.width ? self.scvTrackHolder.verticalRulerView.frame.size.width : newFrame.origin.x;
    self.playheadViewController.knobHeight = self.rulerView.frame.size.height;
    self.playheadViewController.xOffset = self.scvTrackHolder.verticalRulerView.frame.size.width;
    
    [self.playheadViewController.view setFrame:newFrame];
    [self.playheadViewController.view setNeedsDisplay:YES];
}

@end
