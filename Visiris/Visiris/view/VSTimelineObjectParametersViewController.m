//
//  VSTimelineObjectParametersViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSTimelineObjectParametersViewController.h"

#import "VSParameterView.h"
#import "VSParameterViewController.h"
#import "VSParameter.h"
#import "VSScrollView.h"
#import "VSDocument.h"
#import "VSTimelineObject.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectParametersViewController ()

@property NSMutableDictionary *parameterViewControllers;

@end

@implementation VSTimelineObjectParametersViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
@synthesize scrollView = _scrollView;
static NSString* defaultNib = @"VSTimelineObjectParametersView";


#pragma mark - Init

-(id) initWithDefaultNibAndParameterViewHeight:(float)parameterViewHeight{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.parameterViewControllers = [[NSMutableDictionary alloc]init];
        self.parameterViewHeight = parameterViewHeight;
        
        
        self.view.identifier = @"VSTimelineObjectParametersView";
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parameterViewControllers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void) awakeFromNib{
    [self.view setAutoresizingMask:NSViewWidthSizable ];
    [self.view setAutoresizesSubviews:YES];
    
    [self.scrollView setAutoresizingMask:NSViewWidthSizable ];
    [self.scrollView setAutoresizesSubviews:YES];
    
    [self.scrollView.contentView setAutoresizingMask:NSViewWidthSizable];
    [self.scrollView.contentView setAutoresizesSubviews:NO];
}



#pragma mark - Methods

/**
 * Inits and displays a ParameterView for every parameter stored in the timelineObject property
 */
-(void) showParametersOfTimelineObject:(VSTimelineObject*) timelineObject connectedWithDelegate:(id<VSParameterViewKeyFrameDelegate>) delegate{
    
    self.timelineObject = timelineObject;
    self.parameters = self.timelineObject.visibleParameters;
    
    VSParameterViewController *lastParameterController;
    
    if(self.parameters && self.parameters.count){
        
        int i = 0;
        
        for(VSParameter *parameter in self.parameters){
            
            VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNibAndBackgroundColor:i++%2==0?self.evenColor:self.oddColor];
            
            parameteViewController.keyFrameDelegate = delegate;
            
            [parameteViewController showParameter:parameter];
                    
            
            [self.scrollView.documentView addSubview:parameteViewController.view];
            
            
            [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
            [parameteViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.view addConstraints:[self constrainsForParameterView:parameteViewController.view
                                                                 below:lastParameterController.view]];
            
            [self.parameterViewControllers setObject:parameteViewController
                                              forKey:[NSNumber numberWithInteger:parameter.ID]];
            
            lastParameterController = parameteViewController;
        }
        
        [self.view.window recalculateKeyViewLoop];
        
        [self.scrollView.documentView setFrameSize:NSMakeSize(((NSView*)self.scrollView.documentView).frame.size.width, (self.parameters.count) * self.parameterViewHeight)];  
    }
}
 
-(NSArray*) constrainsForParameterView:(NSView*) view below:(NSView*) viewBelow{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObject:view
                                                                forKey:@"parameterView"];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    if(!self.parameterViewControllers.count){
        [self.scrollView.documentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[parameterView(==%f)]",self.parameterViewHeight]
                                                                                             options:0
                                                                                             metrics:nil
                                                                                               views:viewsDictionary]];
    }
    else{
        [constraints addObject: [NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:viewBelow
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0.0]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[parameterView(==%f)]",self.parameterViewHeight]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
    }
    
    return constraints;
}

/**
 * Removes all Parameter views
 */
-(void) resetParameters{
    if(self.parameterViewControllers.count){
        for(VSParameterViewController *ctrl in [self.parameterViewControllers allValues]){
            [ctrl saveParameterAndRemoveObserver];
            [ctrl.view removeFromSuperview];
        }
        
        [self.parameterViewControllers removeAllObjects];
    }
}

-(void) selectKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter{
    ((VSParameterViewController*)[self.parameterViewControllers objectForKey:[NSNumber numberWithInteger:parameter.ID]]).selectedKeyframe = keyFrame;
}

-(void) unselectAllSelectedKeyFrames{
    for(VSParameterViewController *parameterViewController in [self.parameterViewControllers allValues]){
        parameterViewController.selectedKeyframe = nil;
    }
}

@end
