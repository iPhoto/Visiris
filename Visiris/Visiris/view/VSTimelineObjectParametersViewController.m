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
        self.view.identifier = @"VSTimelineObjectParametersView";
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

-(void) awakeFromNib{
    [self.view setAutoresizingMask:NSViewWidthSizable];
    [self.view setAutoresizesSubviews:YES];
}

#pragma mark - Methods

/**
 * Inits and displays a ParameterView for every parameter stored in the timelineObject property
 */
-(void) showParameters:(NSArray *)parameters{
    self.parameters = parameters;
    
    if(parameters && parameters.count){
        for(VSParameter *parameter in self.parameters){
            
            VSParameterViewController *parameteViewController = [[VSParameterViewController alloc] initWithDefaultNib];
            
            if(self.parameterViewControllers.count){
                VSParameterViewController *lastParameterController = [self.parameterViewControllers lastObject];
                [lastParameterController.view setNextKeyView:parameteViewController.view];
            }
            else{
                [self.view.window makeFirstResponder:parameteViewController.view];
            }
            
            [parameteViewController showParameter:parameter];
            
            [self.view addSubview:parameteViewController.view];
            
            
            NSMutableArray *constraints = [[NSMutableArray alloc] init];
            
            NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObject:parameteViewController.view forKey:@"parameterView"];
            
            [constraints addObject: [NSLayoutConstraint constraintWithItem:parameteViewController.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:0.0]];
            
            if(!self.parameterViewControllers.count){
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[parameterView(==%f)]",self.parameterViewHeight]
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:viewsDictionary]];
            }
            else{
                [constraints addObject: [NSLayoutConstraint constraintWithItem:parameteViewController.view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:((VSParameterViewController*) [self.parameterViewControllers lastObject]).view
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0]];
                
                [constraints addObject: [NSLayoutConstraint constraintWithItem:parameteViewController.view
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:((VSParameterViewController*) [self.parameterViewControllers lastObject]).view
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0.0]];
            }
            
            
            [parameteViewController.view setAutoresizingMask:NSViewWidthSizable];
            [parameteViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.view addConstraints:constraints];
            [self.parameterViewControllers addObject:parameteViewController];
            
            DDLogInfo(@"name: %@",parameter.name);
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
