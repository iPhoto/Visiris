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
    [self.deviceParameterComboBox setUsesDataSource:YES];
    self.deviceParameterComboBox.dataSource = self;
    self.deviceParameterComboBox.delegate = self;
    
    [self.deviceComboBox setUsesDataSource:YES];
    self.deviceComboBox.dataSource =self;
    self.deviceComboBox.delegate = self;
}

- (IBAction)didClickToggleConnection:(NSButton *)sender {
    
    VSDeviceParameter *selectedParameter = [self.currentlySelectedDevice objectInParametersAtIndex:[self.deviceParameterComboBox indexOfSelectedItem]];
    
    [self.parameter connectWithDeviceParameter:selectedParameter ofDevice:self.currentlySelectedDevice
                          deviceParameterRange:VSMakeRange([self.deviceParameterMinValueTextField floatValue], [self.deviceParameterMaxValueTextField floatValue])
                             andParameterRange:VSMakeRange([self.parameterMinValueTextField floatValue], [self.parameterMaxValueTextField floatValue])];
    
    [self setToggleButtonStringValue];
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

#pragma mark - NSComboBoxDataSource Implementation

-(id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index{
    id result = nil;
    if([aComboBox isEqual:self.deviceParameterComboBox]){
        if(self.currentlySelectedDevice){
            if(self.currentlySelectedDevice.parameters.count > index){
                result = [self.currentlySelectedDevice objectInParametersAtIndex:index].name;
            }
        }
    }
    else if([aComboBox isEqual:self.deviceComboBox]){
        if(self.availableDevices){
            result = ((VSDevice*)[self.availableDevices objectAtIndex:index]).name;
        }
    }
    
    return result;
}

-(NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox{
    
    NSInteger result = 0;
    if([aComboBox isEqual:self.deviceParameterComboBox]){        
        if(self.currentlySelectedDevice){
            result = self.currentlySelectedDevice.parameters.count;
        }
    }
    else if([aComboBox isEqual:self.deviceComboBox]){
        if(self.availableDevices){
            result = self.availableDevices.count;
        }
    }
    return result;
}

#pragma mark - NSComboBoxDelegate Implementation

-(void) comboBoxSelectionDidChange:(NSNotification *)notification{
    
    if([notification.object isKindOfClass:[NSComboBox class]]){
        NSComboBox *comboBox = ((NSComboBox*)notification.object);
        
        if([comboBox isEqual:self.deviceComboBox]){
            DDLogInfo(@"comboBoxSelectionDidChange deviceComboBox");
            self.currentlySelectedDevice = [self.availableDevices objectAtIndex:[comboBox indexOfSelectedItem]];
            
            [self.deviceParameterComboBox reloadData];
            [self.deviceParameterComboBox selectItemAtIndex:0];
        }
        else if([comboBox isEqual:self.deviceParameterComboBox]){
            DDLogInfo(@"comboBoxSelectionDidChange deviceParameterComboBox");
            self.currentlySelectedDeviceParameter = [self.currentlySelectedDevice objectInParametersAtIndex:[comboBox indexOfSelectedItem]];
        }
    }
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
    
    [self.deviceComboBox reloadData];
    [self.deviceParameterComboBox reloadData];
    
    [self.deviceComboBox selectItemAtIndex:selectedDeviceIndex];
    [self.deviceParameterComboBox selectItemAtIndex:selectedDeviceParameterIndex];
    
    [self setRanges];
}

-(void) setRanges{
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

#pragma mark - Properties

-(void) setCurrentlySelectedDevice:(VSDevice *)currentlySelectedDevice{
    if(![currentlySelectedDevice isEqualTo:_currentlySelectedDevice]){
        _currentlySelectedDevice = currentlySelectedDevice;
        
        [self.deviceComboBox reloadData];
        [self.deviceParameterComboBox reloadData];
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

@end
