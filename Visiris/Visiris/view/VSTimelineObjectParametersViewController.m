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
#import "VSKeyFrame.h"

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
    [self.view setAutoresizesSubviews:YES];
}

#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //observes if new keyFrames have been added or have been removed
    if([keyPath isEqualToString:@"devices"]){
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newDevices = [self.timelineObject devicesAtIndexes:[change valueForKey:@"indexes"]];
                    
                    for(VSDevice *newDevice in newDevices){
                        [self timelineObjectWasConnectedWithDevice:newDevice];
                    }
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if([[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newDevices = [self.timelineObject devicesAtIndexes:[change valueForKey:@"indexes"]];
                    
                    for(VSDevice *newDevice in newDevices){
                        [self timelineObjectWasDisconnectedFromDevice:newDevice];
                    }
                }
                break;
            }
        }
    }
    
}

-(void) timelineObjectWasConnectedWithDevice:(VSDevice*) device{
    for(VSParameterViewController *parameterViewController in [self.parameterViewControllers allValues]){
        [parameterViewController addDeviceConnectorForDevice:device];
    }
    
}

-(void) timelineObjectWasDisconnectedFromDevice:(VSDevice*) device{
    for(VSParameterViewController *parameterViewController in [self.parameterViewControllers allValues]){
        [parameterViewController removeDeviceconnectorForDevice:device];
    }
    
}

#pragma mark - Methods


-(void) showParametersOfTimelineObject:(VSTimelineObject*) timelineObject connectedWithDelegate:(id<VSParameterViewKeyFrameDelegate>) delegate{
    
    self.timelineObject = timelineObject;
    NSArray *parameters = self.timelineObject.visibleParameters;
    
    VSParameterViewController *lastParameterController;
    
    
    [self.timelineObject addObserver:self
                          forKeyPath:@"devices"
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
                             context:nil];
    
    
    if(parameters && parameters.count){
        
        int i = 0;
        
        for(VSParameter *parameter in parameters){
            
            NSColor *backgroundColor = i++%2==0?self.evenColor:self.oddColor;
            
            VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNibAndBackgroundColor:backgroundColor];
            
            [self.view addSubview:parameteViewController.view];
            
            [parameteViewController.view setFrameSize:NSMakeSize( self.view.frame.size.width, parameteViewController.view.frame.size.width)];
            
            [parameteViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            parameteViewController.keyFrameDelegate = delegate;
            [parameteViewController showParameter:parameter andAvailableDevices:self.timelineObject.devices];
            
            [self.view addConstraints:[self constrainsForParameterView:parameteViewController.view
                                                                 below:lastParameterController.view]];
            
            [self.parameterViewControllers setObject:parameteViewController
                                              forKey:[NSNumber numberWithInteger:parameter.ID]];
            
            lastParameterController = parameteViewController;
            
        }
        
        [self.view.window recalculateKeyViewLoop];
        NSRect newFrame = self.view.frame;
        newFrame.size = NSMakeSize(self.view.frame.size.width, (parameters.count) * self.parameterViewHeight);
        
        [self.view setFrame:newFrame];
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
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[parameterView(==%f)]",self.parameterViewHeight]
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
            [ctrl reset];
            [ctrl.view removeFromSuperview];
        }
        
        [self.parameterViewControllers removeAllObjects];
    }
    
    [self.timelineObject removeObserver:self
                             forKeyPath:@"devices"];
    
    self.timelineObject = nil;
}

-(VSParameterViewController*) parameterViewControllRepresnetingParameter:(VSParameter*) parameter{
    VSParameterViewController *result = nil;
    
    
    id object = [self.parameterViewControllers objectForKey:[NSNumber numberWithInteger:parameter.ID]];
    
    if(object && [object isKindOfClass:[VSParameterViewController class]]){
        result = object;
    }
    
    return result;
}

-(void) unselectKeyFrame:(VSKeyFrame *)keyFrame ofParameter:(VSParameter *)parameter{
    VSParameterViewController *viewControllerOfParameter = [self parameterViewControllRepresnetingParameter:parameter];
    
    if(viewControllerOfParameter){
        if([viewControllerOfParameter.selectedKeyframe isEqual:keyFrame]){
            viewControllerOfParameter.selectedKeyframe = nil;
        }
    }
}

-(void) selectKeyFrame:(VSKeyFrame*) keyFrame ofParameter:(VSParameter*) parameter{
    VSParameterViewController *viewControllerOfParameter = [self parameterViewControllRepresnetingParameter:parameter];
    
    if(viewControllerOfParameter){
        viewControllerOfParameter.selectedKeyframe = keyFrame;
    }
}

-(void) unselectAllSelectedKeyFrames{
    for(VSParameterViewController *parameterViewController in [self.parameterViewControllers allValues]){
        parameterViewController.selectedKeyframe = nil;
    }
}

@end
