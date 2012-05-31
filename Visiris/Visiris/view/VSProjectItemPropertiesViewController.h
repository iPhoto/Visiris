//
//  VSProjectItemPropertiesViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class VSProjectItemRepresentation;
@interface VSProjectItemPropertiesViewController : NSViewController<NSUserInterfaceValidations>

#pragma mark - init 

/** VSProjectItemRepresentation properties will be displayed for */
@property (strong) VSProjectItemRepresentation *projectItemRepresentation;

/** Shows the preview image for the VSProjectItemRepresentation */
@property (strong) NSImage *previewImage;

/** VShows the preview of the file if the VSProjectItemRepresentation is a Video */
@property (strong) QTMovie *previewMovie;

/** Box holding the controls showing the properties */
@property (weak) IBOutlet NSBox *bxvPropertiesContainer;

/** Document view of the scroll view */
@property (weak) IBOutlet NSView *documentView;

/** Main Scroll View */
@property (weak) IBOutlet NSScrollView *scrollView;

/** movePreviewView and imagePreviewView are set as subViews if they are needed */
@property (weak) IBOutlet NSView *previewHolder;

/** Holds the Video of the VSProjectItemRepresentation if it is one */
@property (strong)  QTMovieView *moviePreviewView;

/** Preview-Image of the VSProjectItemRepresentation */
@property (strong) NSImageView *imagePreviewView;

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

@end
