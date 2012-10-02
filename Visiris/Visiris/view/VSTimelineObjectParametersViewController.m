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

/** stores the VSKeyFrameViewController instantiated for every VSParameter of the timelineObejct. The ID of the parameter is used as Key. */
@property NSMutableDictionary *parameterViewControllers;

@end

@implementation VSTimelineObjectParametersViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectParametersView";


#pragma mark - Init

-(id) initWithDefaultNibAndParameterViewHeight:(float)parameterViewHeight{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.parameterViewControllers = [[NSMutableDictionary alloc]init];
        self.parameterViewHeight = parameterViewHeight;
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
    
    [((NSView*) self.scrollView.documentView) setAutoresizingMask:NSViewWidthSizable];
}



#pragma mark - Methods


-(void) showParametersOfTimelineObject:(VSTimelineObject*) timelineObject connectedWithDelegate:(id<VSParameterViewKeyFrameDelegate>) delegate{
    
    self.timelineObject = timelineObject;
    NSArray *parameters = self.timelineObject.visibleParameters;
    
    VSParameterViewController *lastParameterController;
    
    if(parameters && parameters.count){
        
        int i = 0;
        
        for(VSParameter *parameter in parameters){
            
            NSColor *backgroundColor = i++%2==0?self.evenColor:self.oddColor;
            
            VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNibAndBackgroundColor:backgroundColor];


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
        
        [self.scrollView.documentView setFrameSize:NSMakeSize(((NSView*)self.scrollView.documentView).frame.size.width, (parameters.count) * self.parameterViewHeight)];  
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


-(void) resetParameters{
    if(self.parameterViewControllers.count){
        for(VSParameterViewController *ctrl in [self.parameterViewControllers allValues]){
            [ctrl saveParameterAndRemoveObserver];
            [ctrl.view removeFromSuperview];
        }
        
        [self.parameterViewControllers removeAllObjects];
    }
    
    self.timelineObject = nil;
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
