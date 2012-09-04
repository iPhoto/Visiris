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

#import "VSCoreServices.h"

@interface VSTimelineObjectParametersViewController ()

@property NSMutableArray *parameterViewControllers;

@end

@implementation VSTimelineObjectParametersViewController

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectParametersView";


#pragma mark - Init

-(id) initWithDefaultNibAndParameterViewHeight:(float)parameterViewHeight{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.parameterViewControllers = [[NSMutableArray alloc]init];
        self.parameterViewHeight = parameterViewHeight;
    }
    
    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parameterViewControllers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Methods

/**
 * Inits and displays a ParameterView for every parameter stored in the timelineObject property
 */
-(void) showParameters:(NSArray *)parameters{
    
    self.parameters = parameters;
    
    if(parameters && parameters.count){
        
        for(VSParameter *parameter in self.parameters){
            
            NSRect viewFrame = NSMakeRect(0, self.parameterViewControllers.count * self.parameterViewHeight, self.view.frame.size.width, self.parameterViewHeight);
            
            VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNib];
            if(self.parameterViewControllers.count){
                VSParameterViewController *lastParameterController = [self.parameterViewControllers lastObject];
                
                [lastParameterController.view setNextKeyView:parameteViewController.view];
            }
            else{
                [self.view.window makeFirstResponder:parameteViewController.view];
            }
            
            
            [self.view addSubview:parameteViewController.view];
            [parameteViewController showParameter:parameter inFrame:viewFrame];
            [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
            [parameteViewController.view setAutoresizesSubviews:YES];
            
            
            
            [self.parameterViewControllers addObject:parameteViewController];
        }
        
        [self.view setFrameSize:NSMakeSize(self.view.frame.size.width, self.parameterViewControllers.count * self.parameterViewHeight)];
    }
}

/**
 * Removes all Parameter views
 */
-(void) resetParameters{
    if(self.parameterViewControllers.count){
        for(VSParameterViewController *ctrl in self.parameterViewControllers){
            [ctrl saveParameterAndRemoveObserver];
            [ctrl.view removeFromSuperview];
        }
        
        [self.parameterViewControllers removeAllObjects];
    }
}

@end
