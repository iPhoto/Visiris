//
//  VSTrackView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTrackView.h"

#import "VSProjectItemRepresentation.h"
#import "VSTimelineObjectViewController.h"

#import "VSCoreServices.h"

@interface VSTrackView()

@property NSDragOperation currentDragOperation;

@end


@implementation VSTrackView

@synthesize controllerDelegate = _controllerDelegate;
@synthesize currentDragOperation = _currentDragOperation;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:VSProjectItemPasteboardType, NSFilenamesPboardType, nil]];
    }
    
    return self;
}

-(void) awakeFromNib{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor darkGrayColor] set];
    NSRectFill(dirtyRect);
}

#pragma mark - Event Handling

-(BOOL) acceptsFirstResponder{
    return YES;
    
}


#pragma mark - MouseEvents

-(void) mouseDown:(NSEvent *)theEvent{
    if([self controllerDelegateImplementsSelector:@selector(didClicktrackView:)]){
        [self.controllerDelegate didClicktrackView:self];
    }
}

-(void) mouseDragged:(NSEvent *)theEvent{
    DDLogInfo(@"Mousedragged on trackView");
}

#pragma mark - VSDraggingDestination implementation

-(NSDragOperation) draggingEntered:(id<NSDraggingInfo>)sender{
    self.currentDragOperation = NSDragOperationNone;
    
    if([self controllerDelegateImplementsSelector:@selector(trackView:objectsHaveEntered:atPosition:)]){
        self.currentDragOperation  = [self.controllerDelegate trackView:self  objectsHaveEntered:sender atPosition:[self convertPoint:[sender draggingLocation] fromView:nil]];
        
        if(self.currentDragOperation  != NSDragOperationNone){
            
            [sender setAnimatesToDestination:NO];
            
            [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages forView:self classes:[NSArray arrayWithObjects:[VSProjectItemRepresentation class], nil]                                        searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                [draggingItem setDraggingFrame:[draggingItem draggingFrame] contents:nil];
            }];
            
        }
        
    }
    
    
    return self.currentDragOperation;
}

-(void) draggingExited:(id<NSDraggingInfo>)sender{
    if([self controllerDelegateImplementsSelector:@selector(trackView:objectHaveExited:)]){
        [self.controllerDelegate trackView:self  objectHaveExited:sender];
        
    }
}


-(BOOL) wantsPeriodicDraggingUpdates{
    return YES;
}



-(BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender{
    
    return YES;
}

-(BOOL) performDragOperation:(id<NSDraggingInfo>)sender{
    if(![self controllerDelegateImplementsSelector:@selector(trackView:objectsHaveBeenDropped:atPosition:)]){
        return NO;
    }
    
    return [self.controllerDelegate trackView:self  objectsHaveBeenDropped:sender atPosition:[self convertPoint:[sender draggingLocation] fromView:nil]];
}

-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender{
    
    if([self controllerDelegateImplementsSelector:@selector(trackView:objectsOverTrack:atPosition:)]){
        [self.controllerDelegate trackView:self  objectsOverTrack:sender atPosition:[self convertPoint:[sender draggingLocation] fromView:nil]];
    }
   

   
    return self.currentDragOperation;
}

#pragma mark- Private Methods

/**
 * Checks if the controllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) controllerDelegateImplementsSelector:(SEL) selector{
    if([self.controllerDelegate conformsToProtocol:@protocol(VSTrackViewDelegate) ]){
        if([self.controllerDelegate respondsToSelector: selector]){
            return YES;
        }
    }
    
    return NO;
}


@end
