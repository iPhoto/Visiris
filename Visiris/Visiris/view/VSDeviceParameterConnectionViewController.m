//
//  VSDeviceParameterConnectionViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 04.10.12.
//
//

#import "VSDeviceParameterConnectionViewController.h"

#import "VSParameter.h"
#import "VSDevice.h"
#import "VSDeviceParameter.h"
#import "VSDeviceParameterMapper.h"
#import "VSDeviceParameterUtils.h"

#import "VSCoreServices.h"

@interface VSDeviceParameterConnectionViewController ()

@property (weak) VSDevice *currentlySelectedDevice;

@property (weak) VSDeviceParameter *currentlySelectedDeviceParameter;

@end

@implementation VSDeviceParameterConnectionViewController

@synthesize currentlySelectedDeviceParameter    = _currentlySelectedDeviceParameter;
@synthesize currentlySelectedDevice             = _currentlySelectedDevice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

-(void) awakeFromNib{
}

- (IBAction)rangeValueDidChange:(id)sender {
    if(self.parameter.connectedWithDeviceParameter){
        [self connectParameterWithDevice];
    }
    
}

- (IBAction)didClickToggleConnection:(NSButton *)sender {
    
    if(!self.parameter.connectedWithDeviceParameter){
        [self connectParameterWithDevice];
    }
    else{
        [self.parameter disconnectFromDevice];
    }
    
    [self.popover close];
}  

-(void) connectParameterWithDevice{
    [self.parameter connectWithDeviceParameter:self.currentlySelectedDeviceParameter
                                      ofDevice:self.currentlySelectedDevice
                          deviceParameterRange:[self deviceParameterRange]
                             andParameterRange:[self parameterRange]];
}

-(VSRange) deviceParameterRange{
    return VSMakeRange([self.deviceParameterMinValueTextField floatValue], [self.deviceParameterMaxValueTextField floatValue]);
}

-(VSRange) parameterRange{
    return VSMakeRange([self.parameterMinValueTextField floatValue], [self.parameterMaxValueTextField floatValue]);
    
}

-(void) setToggleButtonStringValue{
    if(self.parameter.connectedWithDeviceParameter){
        [self.toogleConnection setTitle:NSLocalizedString(@"Disconnect Device", @"toogleConnection Button Caption")];
    }
    else
    {
        [self.toogleConnection setTitle:NSLocalizedString(@"Connect Device", @"toogleConnection Button Caption")];
    }
}

-(id) initWithDevice:(VSDevice*) device andParameter:(VSParameter*) parameter{
    if(self = [super init]){
        self.currentlySelectedDevice = device;
        self.parameter = parameter;
    }
    
    return self;
}


-(void) showConnectionDialogFor:(VSParameter*) parameter andAvailableDevices:(NSArray*) availableDevices{
    self.parameter = parameter;
    self.availableDevices = availableDevices;
    
    NSUInteger selectedDeviceIndex = 0;
    NSUInteger selectedDeviceParameterIndex = 0;
    
    self.currentlySelectedDevice = [self.availableDevices objectAtIndex:0];
    
    if(self.parameter.connectedWithDeviceParameter){
        self.currentlySelectedDevice = self.parameter.deviceConnectedWith;
        selectedDeviceIndex = [self.availableDevices indexOfObject:self.currentlySelectedDevice];
        selectedDeviceParameterIndex = [self.currentlySelectedDevice indexOfObjectInParameters:self.parameter.deviceParamterConnectedWith];
    }
    
    [self setRanges];
    [self setToggleButtonStringValue];
    
    NSInteger i = 0;
    
    [self.devicePopUpButton removeAllItems];
    
    for(VSDevice *availableDevice in self.availableDevices){
        if(availableDevice.parameters.count)
            [self.devicePopUpButton insertItemWithTitle:availableDevice.name atIndex:i++];
    }
}

-(void) setRanges{
    
    if(self.parameter.hasRange && self.currentlySelectedDeviceParameter.hasRange)
    {
        
        if([self.mappingHolderBox isHidden]){
            NSSize newSize = self.popover.contentSize;
            newSize.height += self.mappingHolderBox.frame.size.height;
            
            [self.popover setContentSize:newSize];
        }
        
        [self.mappingHolderBox setHidden:NO];
        
        
        
        if(self.parameter.connectedWithDeviceParameter && [self.currentlySelectedDeviceParameter isEqual:self.parameter.deviceParamterConnectedWith] && [self.currentlySelectedDevice isEqual:self.parameter.deviceConnectedWith]){
            if(self.parameter.deviceParameterMapper.hasRanges){
                [self.parameterMinValueTextField setFloatValue:self.parameter.deviceParameterMapper.parameterRange.min];
                [self.parameterMaxValueTextField setFloatValue:self.parameter.deviceParameterMapper.parameterRange.max];
                
                [self.deviceParameterMinValueTextField setFloatValue:self.parameter.deviceParameterMapper.deviceParameterRange.min];
                [self.deviceParameterMaxValueTextField setFloatValue:self.parameter.deviceParameterMapper.deviceParameterRange.max];
            }
            else{
                
            }
        }
        else{
            if(self.parameter.hasRange && self.currentlySelectedDeviceParameter.hasRange){
                [self.parameterMinValueTextField setFloatValue:self.parameter.range.min];
                [self.parameterMaxValueTextField setFloatValue:self.parameter.range.max];
                
                [self.deviceParameterMinValueTextField setFloatValue:self.currentlySelectedDeviceParameter.range.min];
                [self.deviceParameterMaxValueTextField setFloatValue:self.currentlySelectedDeviceParameter.range.max];
            }
            else{
                
            }
        }
    }
    else{
        
        if(![self.mappingHolderBox isHidden]){
            NSSize newSize = self.popover.contentSize;
            newSize.height -= self.mappingHolderBox.frame.size.height;
            
            [self.popover setContentSize:newSize];
        }
        
        [self.mappingHolderBox setHidden:YES];
    }
}

-(void) reloadDeviceParameterPopUp{
    [self.deviceParameterPopUpButton removeAllItems];
    
    [self.deviceParameterPopUpButton setAutoenablesItems:NO];
    
    NSUInteger indexToSelect = 0;
    
    for(NSUInteger i = 0; i < self.currentlySelectedDevice.parameters.count; i++){
        VSDeviceParameter *deviceParameter = [self.currentlySelectedDevice objectInParametersAtIndex:i];
        
        [self.deviceParameterPopUpButton insertItemWithTitle:deviceParameter.name atIndex:i];
        
        if(![VSDeviceParameterUtils deviceParameterDataype:deviceParameter.dataType validForParameterType:self.parameter.dataType]){
            [[self.deviceParameterPopUpButton itemAtIndex:i] setEnabled:NO];
            
            if(i == indexToSelect){
                indexToSelect++;
            }
        }
    }
    
    [self.deviceParameterPopUpButton selectItemAtIndex:indexToSelect];
    self.currentlySelectedDeviceParameter = [self.currentlySelectedDevice objectInParametersAtIndex:indexToSelect];
}

#pragma mark - Properties

-(void) setCurrentlySelectedDevice:(VSDevice *)currentlySelectedDevice{
    if(![currentlySelectedDevice isEqualTo:_currentlySelectedDevice]){
        _currentlySelectedDevice = currentlySelectedDevice;
        
        [self reloadDeviceParameterPopUp];
    }
}

-(VSDevice*) currentlySelectedDevice{
    return _currentlySelectedDevice;
}

-(void) setCurrentlySelectedDeviceParameter:(VSDeviceParameter *)currentlySelectedDeviceParameter{
    if(![currentlySelectedDeviceParameter isEqualTo:_currentlySelectedDeviceParameter]){
        _currentlySelectedDeviceParameter = currentlySelectedDeviceParameter;
        
        [self setRanges];
    }
}

-(VSDeviceParameter*) currentlySelectedDeviceParameter{
    return _currentlySelectedDeviceParameter;
}

- (IBAction)didChangeDevicePopUpButton:(NSPopUpButton *)sender {
    self.currentlySelectedDevice = [self.availableDevices objectAtIndex:[sender indexOfSelectedItem]];
    
    if(self.parameter.connectedWithDeviceParameter){
        [self connectParameterWithDevice];
    }
}

- (IBAction)didChangeDeviceParameterPopUpButton:(NSPopUpButton *)sender {
    self.currentlySelectedDeviceParameter = [self.currentlySelectedDevice objectInParametersAtIndex:[sender indexOfSelectedItem]];
    
    if(self.parameter.connectedWithDeviceParameter){
        [self connectParameterWithDevice];
    }
}
@end
