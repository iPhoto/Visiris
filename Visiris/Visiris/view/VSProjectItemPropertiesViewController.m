//
//  VSProjectItemPropertiesViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItemPropertiesViewController.h"
#import "VSProjectItemRepresentation.h"
#import "VSFileType.h"

#import "VSCoreServices.h"

@interface VSProjectItemPropertiesViewController ()

@end

@implementation VSProjectItemPropertiesViewController

@synthesize projectItemRepresentation = _projectItemRepresentation;
@synthesize previewImage =_previewImage;
@synthesize bxvPropertiesContainer = _bxvPropertiesContainer;
@synthesize documentView = _documentView;
@synthesize scrollView = _scrollView;
@synthesize previewHolder = _previewHolder;
@synthesize moviePreviewView = _moviePreview;
@synthesize imagePreviewView = _imagePreviewView;
@synthesize previewMovie = _previewMovie;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSProjectItemPropertiesView";

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

-(void) initScrollView{
    // Inits the scroll view
    
    [self.scrollView setDocumentView:self.documentView];
    [self.documentView setAutoresizesSubviews:YES];
    [self.documentView setAutoresizingMask: NSViewWidthSizable];
    
    [self.previewHolder setAutoresizesSubviews:YES];
}

#pragma mark - NSViewController

-(void) awakeFromNib{
    
    [self initScrollView];
    
    self.imagePreviewView = [[NSImageView alloc] initWithFrame:self.previewHolder.frame];
    [self.imagePreviewView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self.imagePreviewView setImageAlignment:NSImageAlignCenter];
    [self.imagePreviewView setAutoresizingMask:NSViewWidthSizable |NSViewHeightSizable];
    
    self.moviePreviewView = [[QTMovieView alloc] initWithFrame:self.previewHolder.frame];
    [self.moviePreviewView setPreservesAspectRatio:YES];
    [self.moviePreviewView setFillColor:[NSColor blackColor]];
    [self.moviePreviewView setEditable:NO];
    [self.moviePreviewView setControllerVisible:NO];
    [self.moviePreviewView setAutoresizingMask:NSViewWidthSizable |NSViewHeightSizable];
    
    [self.previewHolder addSubview:self.imagePreviewView];
}

#pragma mark - NSUserInterfaceValidations

-(BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem{
    return YES;
}

#pragma mark - Private Methods

/**
 * Shows a image oder video preview according to the type of file represented by the controllers projectItemRepresentation property.
 */
-(void) showPreview{
    
    if(self.previewMovie)
        [self.previewMovie stop];
    
    if(self.projectItemRepresentation.fileType.fileKind == VSFileKindVideo){
        
        self.previewMovie = [[QTMovie alloc] initWithFile:self.projectItemRepresentation.filePath error:nil];
        [self.moviePreviewView setMovie:self.previewMovie];
        [self.previewHolder replaceSubview:[self.previewHolder.subviews objectAtIndex:0] with:self.moviePreviewView];
        
        NSRect frame = NSMakeRect(0, 0, self.previewHolder.frame.size.width, self.previewHolder.frame.size.height);
        [self.moviePreviewView setFrame:NSIntegralRect(frame)];

        [self.view setNeedsDisplay:YES];
    }
    else{
        
        self.previewImage = [VSFileImageCreator createIamgeForFile:self.projectItemRepresentation.filePath withWidht:640 withHeight:480];
        if([[self.previewHolder subviews] objectAtIndex:0] != self.imagePreviewView ){
            [self.previewHolder replaceSubview:[self.previewHolder.subviews objectAtIndex:0] with:self.imagePreviewView];
        }
        [self.imagePreviewView setImage:self.previewImage];
        NSRect frame = NSMakeRect(0, 0, self.previewHolder.frame.size.width, self.previewHolder.frame.size.height);
        [self.imagePreviewView setFrame:frame];
        
        
        [self.previewHolder setNeedsDisplay:YES];
    }
}



#pragma mark - Properties

-(void) setProjectItemRepresentation:(VSProjectItemRepresentation *)projectItemRepresentation{
    if(projectItemRepresentation != self.projectItemRepresentation){
        _projectItemRepresentation = projectItemRepresentation;
        [self showPreview];
    }
}


-(VSProjectItemRepresentation *) projectItemRepresentation{
    return _projectItemRepresentation;
 }

@end
