//
//  VSProjectItemBrowserViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Responsible for Displaying the files available in the current Visirs-Project.
 *
 * The VSProjectItemBrowsercontroller creates VSProjectItemRepresentations for all VSProjectItems and takes care about keeping them up-to-date. The controller manages the drag'n'drop ability of the items it shows and gives so the possibilty to add VSProjectItems to the timeline. For this purpose the controlelr acts as DataSource for the tableView in the nil.
 *
 * Throws VSProjectItemRepresentationGotSelected and VSProjectItemRepresentationGotUnselected notifications
 */
@interface VSProjectItemBrowserViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

/** Displays all VSProjectItemRepresentations */
@property (weak) IBOutlet NSTableView *tvwProjectItmes;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

@end
