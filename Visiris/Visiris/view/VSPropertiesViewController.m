//
//  VSPropertiesViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSPropertiesViewController.h"

#import "VSProjectItemPropertiesViewController.h"
#import "VSTimelineObjectPropertiesViewController.h"
#import "VSProjectItemRepresentation.h"
#import "VSTimelineObject.h"

#import "VSCoreServices.h"

@interface VSPropertiesViewController ()

/** Disyplays the properties of VSProjectItems */
@property (strong) VSProjectItemPropertiesViewController *projectItemPropertiesViewController;

/** Disyplays the properties of VSProjectItems */
@property (strong) VSTimelineObjectPropertiesViewController *timelineObjectPropertiesViewController;

@end

@implementation VSPropertiesViewController

@synthesize projectItemPropertiesViewController = _projectItemPropertiesViewController;
@synthesize timelineObjectPropertiesViewController = _timelineObjectPropertiesViewController;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSPropertiesView";

#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
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

#pragma mark - NSViewController

-(void) awakeFromNib{

    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.view setAutoresizesSubviews:YES];
    
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.view setAutoresizesSubviews:YES];
    
    
    //inits the two properties subviews
    self.projectItemPropertiesViewController = [[VSProjectItemPropertiesViewController alloc] initWithDefaultNib];
    self.timelineObjectPropertiesViewController = [[VSTimelineObjectPropertiesViewController alloc] initWithDefaultNib];

    
    [self initObservers];
}

-(void) initObservers{
    //Adding Observer for Project Items got selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectItemsRepresentationsGotSelected:) name:VSProjectItemRepresentationGotSelected object:nil];
    
    //Adding Observer for Project Items got unselected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectItemsRepresentationsGotUnselected:) name:VSProjectItemRepresentationGotUnselected object:nil];
    
    //Adding Observer for TimelineObjects got selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineObjectsGotSelected:) name:VSTimelineObjectsGotSelected object:nil];
    
    //Adding Observer for TimelineObjects got unselected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineObjectsGotUnselected:) name:VSTimelineObjectsGotUnselected object:nil];
}

#pragma mark - Private Methods

/**
 * Called when a VSProjectItemRepresentationGotSelected-Notification was received.
 *
 * Calls the ProjectItemPropertyView to show the properties of the VSProjectItemRepresentation stored in the notification's object
 * @param notification Holding the selected VSProjectItemRepresentation
 */
-(void) projectItemsRepresentationsGotSelected:(NSNotification *) notification{
    if([notification.object isKindOfClass:[NSArray class] ]){
        
        if([[((NSArray*) notification.object) objectAtIndex:0] isKindOfClass:[VSProjectItemRepresentation class]]){
            VSProjectItemRepresentation *selectedProjectItemRepresentation = ((VSProjectItemRepresentation*) [((NSArray*) notification.object) objectAtIndex:0]);
            [self showSubview:self.projectItemPropertiesViewController.view];
            self.projectItemPropertiesViewController.projectItemRepresentation = selectedProjectItemRepresentation;
        }
    }
}

/**
 * Called when a VSProjectItemRepresentationGotUnselected-Notification was received.
 *
 * Hides the currently visible ProjectItemProperties view
 * @param notification NSNotification storing the VSProjectItemRepresentations got unselected.
 */
-(void) projectItemsRepresentationsGotUnselected:(NSNotification *) notification{
    DDLogInfo(@"projectItemsRepresentationsGotUnselected: %@  NOT IMPLEMENTED YET", notification);    
}

/**
 * Called when a VSTimelineObjectsGotSelected-Notification was received.
 *
 * Calls the TimelineObjectPropertyView to show the properties of the VSTimelineObject stored in the notification's object
 * @param notification Holding the selected VSTimelineObject
 */
-(void) timelineObjectsGotSelected:(NSNotification *) notification{

    if([[notification object] isKindOfClass:[NSArray class]]){
        NSArray *selectedTimelineObjects = (NSArray*) [notification object];
        
        if(selectedTimelineObjects && selectedTimelineObjects.count > 0){
            if([[selectedTimelineObjects objectAtIndex:0] isKindOfClass:[VSTimelineObject class]]){
                VSTimelineObject *timelineObject = (VSTimelineObject*) [selectedTimelineObjects objectAtIndex:0];
            [self showSubview:self.timelineObjectPropertiesViewController.view];
            self.timelineObjectPropertiesViewController.timelineObject = timelineObject;
            }
        }
    }
}

/**
 * Called when a VSTimelineObjectsGotUnselected-Notification was received.
 *
 * Hides the currently visible TimelineObjectPropertyView
 * @param notification NSNotification storing the selected VSTimelineObject
 */
-(void) timelineObjectsGotUnselected:(NSNotification *) notification{
    if(self.view.subviews.count > 0){
        if([[self.view subviews] objectAtIndex:0] == self.timelineObjectPropertiesViewController.view){
            [self.timelineObjectPropertiesViewController willBeHidden];
            [self.timelineObjectPropertiesViewController.view removeFromSuperview];
        }
    }
}

/**
 * Replaces the contenView's current subView with the given one and inits it.
 * @param subView NSView to show as subView of the contentView
 */
-(void) showSubview:(NSView*) subView{
    
    if(!self.view.subviews.count){
        [self.view addSubview:subView];
        
    }
    else if([[self.view subviews] objectAtIndex:0] != subView){
        
        //Sends a notification if the timelineObjects Properties are hidden
        if([[self.view subviews] objectAtIndex:0] == self.timelineObjectPropertiesViewController.view){
            [[NSNotificationCenter defaultCenter] postNotificationName:VSTimelineObjectPropertiesDidTurnInactive object:[NSArray arrayWithObject:self.timelineObjectPropertiesViewController.timelineObject]];
        }
        
        //Neccessary to check once more if the contentView has any subviews because timelineObjectsGotUnselected got have been called meanwhile
        if(!self.view.subviews.count)
            [self.view addSubview:subView];
        else
            [self.view replaceSubview:[self.view.subviews objectAtIndex:0] with:subView];
    }
    
    NSRect frame = self.view.frame;
    frame.origin = NSZeroPoint;
    
    [subView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [subView setAutoresizesSubviews:YES];
    
    [subView setFrame:frame];
    
    
}

@end
