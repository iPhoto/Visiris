//
//  VSTimelineObjectViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "VSTimelineObjectProxy.h"
#import "VSTimelineObjectView.h"
#import "VStimelineObject.h"
#import "VSTimelineObjectViewIntersection.h"
#import "VSDeviceManager.h"
#import "VSDocument.h"
#import "VSDeviceRepresentation.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectViewController()

@property double pixelTimeRatio;

@property (weak) VSDeviceManager *deviceManager;

@property NSMutableArray *deviceIconLayers;

@property (strong,readwrite) VSTimelineObjectProxy* timelineObjectProxy;

@end


@implementation VSTimelineObjectViewController

#define VIEWS_HIGHLIGHTED_ZPOSITION 20
#define DEVICE_ICON_ZPOSITION 30
#define VIEWS_DEFAULT_ZPOSITION 10
#define DEVICE_ICON_WIDTH 30
#define DEVICE_ICON_HEIGHT 30
#define DEVICE_ICON_MARGIN 5


@synthesize pixelTimeRatio                  = _pixelTimeRatio;
@synthesize delegate                        = _delegate;
@synthesize timelineObjectProxy             = _timelineObjectProxy;
@synthesize temporary                       = _temporary;
@synthesize moving                          = _moving;
@synthesize inactive                        = _inactive;
@synthesize intersectedTimelineObjectViews  = _intersectedTimelineObjectViews;
@synthesize timelineObjectView              = _timelineObjectView;
@synthesize viewsDoubleFrame                = _viewsDoubleFrame;


/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectView";

-(id) initWithDefaultNibAndTimelineObjectProxy:(VSTimelineObjectProxy *)timelineObjectProxy{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        
        _intersectedTimelineObjectViews = [[NSMutableDictionary alloc] init];
        if([self.view isKindOfClass:[VSTimelineObjectView class]]){
            self.timelineObjectView = (VSTimelineObjectView*) self.view;
            self.timelineObjectView.delegate = self;
            self.inactive = NO;
            
        }
        self.deviceIconLayers = [[NSMutableArray alloc]init];
        self.timelineObjectProxy = timelineObjectProxy;
        [self initTimelineObjectProxyObservers];
        
        [self showDeviceIcons];
        
//        if(self.timelineObject.fileType.fileKind == VSFileKindVideo || self.timelineObject.fileType.fileKind == VSFileKindAudio){
//            NSImage *testImage = [VSWaveForm WaveformOfFile:self.timelineObject.filePath];
//            [self.waveFormTest setImage:testImage];
//        }
    }
    
    return self;
}

-(void) awakeFromNib{
    [self.view setAutoresizingMask:NSViewHeightSizable];
}

-(void) initTimelineObjectProxyObservers{
    
    [self.timelineObjectProxy addObserver:self
                               forKeyPath:@"selected"
                                  options:0
                                  context:nil];
    
    [self.timelineObjectProxy addObserver:self
                               forKeyPath:@"duration"
                                  options:0
                                  context:nil];
    
    [self.timelineObjectProxy addObserver:self
                               forKeyPath:@"startTime"
                                  options:0
                                  context:nil];
    
    if([self.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        [self.timelineObjectProxy addObserver:self
                                   forKeyPath:@"devices"
                                      options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionPrior
                                      context:nil];
    }
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //if the selection-state of the observed TimelineObject has been changed, the view is set selected or unselected
    if([keyPath isEqualToString:@"selected"]){
        if(self.view){
            if([self.view isKindOfClass:[VSTimelineObjectView class]]){
                BOOL selected = [[object valueForKey:keyPath] boolValue];
                if(((VSTimelineObjectView*)self.view).selected != selected){
                    ((VSTimelineObjectView*)self.view).selected = selected;
                    
                    if(selected){
                        
                        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasSelected:)]){
                            [self.delegate timelineObjectProxyWasSelected:self.timelineObjectProxy];
                        }
                    }
                    else {
                        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasUnselected:)]){
                            [self.delegate timelineObjectProxyWasUnselected:self.timelineObjectProxy];
                        }
                        
                    }
                    
                    [self.view setNeedsDisplayInRect:self.view.visibleRect];
                }
            }
        }
    }
    
    else if([keyPath isEqualToString:@"duration"] || [keyPath isEqualToString:@"startTime"]){
        [self setViewsFrameAccordingToTimelineObject];
    }
    
    else if([keyPath isEqualToString:@"devices"]){
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSIndexSet *indicesOfNewDevices = [change valueForKey:@"indexes"];
                    
                    NSArray *newDevices = [self.timelineObject devicesAtIndexes:indicesOfNewDevices];
                    
                    NSUInteger currentIndex = [indicesOfNewDevices firstIndex];
                    
                    for(VSDevice *newDevice in newDevices){

                        [self newDeviceWasAdded:newDevice atIndex:currentIndex];
                        
                        currentIndex = [indicesOfNewDevices indexGreaterThanIndex:currentIndex];
                    }
                }
                
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    [self updateDeviceIcons];
                }
                break;
            }
        }
    }
}

-(void) dealloc{
    [self.timelineObjectProxy removeObserver:self forKeyPath:@"selected"];
    [self.timelineObjectProxy removeObserver:self forKeyPath:@"duration"];
    [self.timelineObjectProxy removeObserver:self forKeyPath:@"startTime"];

    if([self.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        [self.timelineObjectProxy removeObserver:self
                                      forKeyPath:@"devices"];
    }
    
    self.timelineObjectProxy = nil;
}

#pragma mark - VSTimelineObjectViewDelegate implementation

-(void) timelineObjectViewWasClicked:(VSTimelineObjectView *)timelineObjectView withModifierFlags:(NSUInteger)modifierFlags {
    
    //if the commandKey was pressed while the timelineObjectView was clicked it's selected additionally othwise it selected exclusively and the currenlty selected objects get unselected
    BOOL exclusiveSelection = !(modifierFlags & NSCommandKeyMask);
    
    if(!self.timelineObjectProxy.selected){
        if([self delegateRespondsToSelector:@selector(timelineObjectProxyWillBeSelected:exclusively:)]){
            [self.delegate timelineObjectProxyWillBeSelected:self.timelineObjectProxy exclusively:exclusiveSelection];
        }
    }
}

-(NSPoint) timelineObjectViewWillBeDragged:(VSTimelineObjectView *)timelineObjectView fromPosition:(NSPoint)oldPosition toPosition:(NSPoint)newPosition forMousePosition:(NSPoint)currentMousePosition{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillBeDragged:fromPosition:toPosition:forMousePosition:)]){
        return [self.delegate timelineObjectWillBeDragged:self fromPosition:oldPosition toPosition:newPosition forMousePosition:currentMousePosition];
    }
    
    return newPosition;
}

-(void) timelineObjectViewWasDragged:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWasDragged:)]){
        [self.delegate timelineObjectWasDragged:self];
    }
}

-(BOOL) timelineObjectViewWillStartDragging:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillStartDragging:)]){
        return [self.delegate timelineObjectWillStartDragging:self];
    }
    
    return NO;
}

-(void)timelineObjectDidStopDragging:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectDidStopDragging:)]){
        [self.delegate timelineObjectDidStopDragging:self];
    }
    //after the moving or resizing of the timeline object is done, the position and length are updated according to the startTime and duration stored in the timelineObject-Proxy property
    [self setViewsFrameAccordingToTimelineObject];
}

-(BOOL) timelineObjectWillStartResizing:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillStartResizing:)]){
        return [self.delegate timelineObjectWillStartResizing:self];
    }
    
    return NO;
}

-(VSDoubleFrame) timelineObjectWillResize:(VSTimelineObjectView *)timelineObjectView fromFrame:(VSDoubleFrame)oldFrame toFrame:(VSDoubleFrame)newFrame{
    if([self delegateRespondsToSelector:@selector(timelineObjectWillResize:fromFrame:toFrame:)]){
        return [self.delegate timelineObjectWillResize:self fromFrame:oldFrame toFrame:newFrame];
    }
    
    return newFrame;
}

-(void) timelineObjectDidStopResizing:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectDidStopResizing:)]){
        [self.delegate timelineObjectDidStopResizing:self];
    }
}

-(void) timelineObjectViewWasResized:(VSTimelineObjectView *)timelineObjectView{
    if([self delegateRespondsToSelector:@selector(timelineObjectProxyWasResized:)]){
        [self.delegate timelineObjectProxyWasResized:self];
    }
}

-(BOOL) draggingInfo:(id<NSDraggingInfo>)draggingInfo isDroppedOnTimelineObjectView:(VSTimelineObjectView *)timelineObjectView{
    BOOL result = NO;
    
    NSArray *clasesToReadFromPasteboard = [NSArray arrayWithObject:[VSDeviceRepresentation class]];
    
    if([[draggingInfo draggingPasteboard] canReadObjectForClasses:clasesToReadFromPasteboard options:nil]){
        NSArray *draggedDeviceRepresentations = [NSMutableArray arrayWithArray:[[draggingInfo draggingPasteboard]
                                                              readObjectsForClasses:clasesToReadFromPasteboard
                                                              options:nil]];
        
        
        
        if(draggedDeviceRepresentations.count){
            if([self delegateRespondsToSelector:@selector(devices:wereDroppedOnTimlineObject:)]){
                [self.delegate devices:draggedDeviceRepresentations wereDroppedOnTimlineObject:self];
            }
        }
        
        result = YES;
        
        
    }
    
   
    return result;
}

-(NSDragOperation) draggingOperationWithDraggingInfo:(id<NSDraggingInfo>)draggingInfo hasEnteredTimelineObjectView:(VSTimelineObjectView *)timelineObjectView{
    
    NSDragOperation result = NSDragOperationNone;
    
    NSArray *clasesToReadFromPasteboard = [NSArray arrayWithObject:[VSDeviceRepresentation class]];
    
    if([[draggingInfo draggingPasteboard] canReadObjectForClasses:clasesToReadFromPasteboard options:nil]){
        
        result = NSDragOperationLink;
    }
    
    return result;
}

-(void) draggingOperationWithDraggingInfo:(id<NSDraggingInfo>)draggingInfo hasExitedTimelineObjectView:(VSTimelineObjectView *)timelineObjectView{
    
}

#pragma mark - Methods

-(void) changePixelTimeRatio:(double)newPixelTimeRatio{
    if(newPixelTimeRatio != self.pixelTimeRatio){
        self.pixelTimeRatio = newPixelTimeRatio;
        [self setViewsFrameAccordingToTimelineObject];
    }
}

-(void) intersectedByTimelineObjectView:(VSTimelineObjectViewController *)timelineObjectViewController atRect:(NSRect)intersectionRect{
    
    NSNumber *key = [NSNumber numberWithInteger: timelineObjectViewController.timelineObjectProxy.timelineObjectID];
    
    VSTimelineObjectViewIntersection *intersection = [self.intersectedTimelineObjectViews objectForKey:key];
    
    if(intersection){
        if(!NSEqualRects(intersection.rect, intersectionRect)){
            intersection.rect = intersectionRect;
        }
    }
    else {
        
        CALayer *intersectionLayer = nil;
        
        
        if(self.timelineObjectView){
            intersectionLayer = [self.timelineObjectView addIntersectionLayerForRect:intersectionRect];
        }
        
        intersection = [[VSTimelineObjectViewIntersection alloc] initWithIntersectedTimelineObejctView:timelineObjectViewController intersectedAt:intersectionRect andLayer:intersectionLayer];
        
        [self.intersectedTimelineObjectViews setObject:intersection forKey:key];
    }
    
    if(intersection.layer){
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        intersection.layer.frame = intersection.rect;
        [CATransaction commit];
    }
}

-(void) removeIntersectionWith:(VSTimelineObjectViewController *)timelineObjectViewController{
    NSNumber *key = [NSNumber numberWithInteger: timelineObjectViewController.timelineObjectProxy.timelineObjectID];
    
    if(self.intersectedTimelineObjectViews && self.intersectedTimelineObjectViews.count){
        VSTimelineObjectViewIntersection *intersection =  (VSTimelineObjectViewIntersection*) [self.intersectedTimelineObjectViews objectForKey:key];
        
        if(intersection){
            if(self.timelineObjectView){
                if(intersection.layer){
                    [self.timelineObjectView removeIntersectionLayer:intersection.layer];
                }
            }
            [self.intersectedTimelineObjectViews removeObjectForKey:key];
        }
    }
}

-(void) removeAllIntersections{
    
    if(self.timelineObjectView){
        for(VSTimelineObjectViewIntersection *intersection in [self.intersectedTimelineObjectViews allValues]){
            if(intersection){
                [self.timelineObjectView removeIntersectionLayer:intersection.layer];
            }
        }
    }
    
    [self.intersectedTimelineObjectViews removeAllObjects];
    
}

#pragma mark - Private Methods

/**
 * Sets the frame of the view according to timelineObjectProxies startTime and duration.
 */
-(void) setViewsFrameAccordingToTimelineObject{
    
    if(self.view && self.pixelTimeRatio > 0){
        VSDoubleFrame newFrame;
        newFrame.x = self.timelineObjectProxy.startTime / self.pixelTimeRatio;
        newFrame.width = self.timelineObjectProxy.duration / self.pixelTimeRatio;
        newFrame.height = self.view.frame.size.height;
        newFrame.y = 0;
        
        [self setViewsDoubleFrame:newFrame];
        
        [self.view setNeedsDisplayInRect:self.view.visibleRect];
    }
}

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSTimelineObjectControllerDelegate) ]){
            if([self.delegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

-(void) newDeviceWasAdded:(VSDevice*) newDevice atIndex:(NSUInteger) index{
    CALayer *deviceLayer = [[CALayer alloc] init];
    
    NSRect layerRect = NSMakeRect(0, self.view.frame.origin.y, DEVICE_ICON_WIDTH, DEVICE_ICON_HEIGHT);
    
    if(self.deviceIconLayers.count){
        layerRect.origin = NSMakePoint(NSMaxX(((CALayer*)[self.deviceIconLayers objectAtIndex:0]).frame) +DEVICE_ICON_MARGIN, layerRect.origin.y);
    }    
    [deviceLayer setFrame:layerRect];
    
    deviceLayer.backgroundColor = [[NSColor greenColor] CGColor];
    
    [self.view.layer addSublayer:deviceLayer];
    
    [self.deviceIconLayers insertObject:deviceLayer atIndex:index];
}

-(void) updateDeviceIcons{
    for(CALayer *subLayer in self.deviceIconLayers){
        [subLayer removeFromSuperlayer];
    }
    
    [self.deviceIconLayers removeAllObjects];
    
    [self showDeviceIcons];
}

-(void) showDeviceIcons{
    if(self.timelineObject){
        for (VSDevice* device in self.timelineObject.devices){
            [self newDeviceWasAdded:device atIndex:[self.timelineObject.devices indexOfObject:device]];
        }
    }
}

#pragma mark - Propertes

-(BOOL) temporary{
    return _temporary;
}

-(void) setTemporary:(BOOL)temporary{
    if(self.timelineObjectView){
        self.timelineObjectView.temporary = temporary;
        if(temporary != _temporary){
            [self.view setNeedsDisplayInRect:self.view.visibleRect];
            
            if(temporary){
                [self.view.layer setZPosition:VIEWS_HIGHLIGHTED_ZPOSITION];
            }
            else {
                [self.view.layer setZPosition:VIEWS_DEFAULT_ZPOSITION];
            }
        }
        
        _temporary = temporary;
    }
}

-(void) setMoving:(BOOL)moving{
    if(moving != _moving){
        if(self.timelineObjectView){
            self.timelineObjectView.moving = moving;
            
            //the zPosition of the views layer is changed according to the moving flag
            if(moving){
                [self.view.layer setZPosition:VIEWS_HIGHLIGHTED_ZPOSITION];
            }
            else {
                [self.view.layer setZPosition:VIEWS_DEFAULT_ZPOSITION];
            }
            
            [self.view setNeedsDisplayInRect:self.view.visibleRect];
            
        }
    }
    _moving = moving;
}

-(BOOL) moving{
    return _moving;
}

-(BOOL) inactive{
    return _inactive;
}

-(void) setInactive:(BOOL)inactive{
    if(self.timelineObjectView){
        self.timelineObjectView.inactive = inactive;
        if(inactive != _inactive)
            [self.view setNeedsDisplayInRect:self.view.visibleRect];
    }
    
    _inactive = inactive;
}


-(void) setViewsDoubleFrame:(VSDoubleFrame)viewsDoubleFrame{
    if(!VSEqualDoubleFrame(self.timelineObjectView.doubleFrame, viewsDoubleFrame)){
        self.timelineObjectView.doubleFrame = viewsDoubleFrame;
    }
}

-(VSDoubleFrame) viewsDoubleFrame{
    return self.timelineObjectView.doubleFrame;
}

-(VSTimelineObject*) timelineObject{
    if([self.timelineObjectProxy isKindOfClass:[VSTimelineObject class]]){
        return (VSTimelineObject*) self.timelineObjectProxy;
    }
    else{
        return nil;
    }
}

@end
