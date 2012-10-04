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

@interface VSDeviceParameterConnectionViewController ()

@property (weak) VSDevice *currentlySelectedDevice;

@end

@implementation VSDeviceParameterConnectionViewController

@synthesize availableDevices = _availableDevices;
@synthesize parameter   = _parameter;

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
    
    [self.deviceComboBox setUsesDataSource:YES];
    self.deviceComboBox.dataSource =self;
}

- (IBAction)didClickToggleConnection:(NSButton *)sender {
    
    VSDeviceParameter *selectedParameter = [self.currentlySelectedDevice objectInParametersAtIndex:[self.deviceParameterComboBox indexOfSelectedItem]];
    
    [self.parameter connectWithDeviceParameter:selectedParameter ofDevice:self.currentlySelectedDevice
                          deviceParameterRange:VSMakeRange(0, 100)
                             andParameterRange:VSMakeRange(0, 10)];
    
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
    
    DDLogInfo(@"objectValueForItemAtIndex %@",result);
    
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
            DDLogInfo(@"numberOfItemsInComboBox for dev %@ %ld",aComboBox,result);
        }
    }
    
    DDLogInfo(@"numberOfItemsInComboBox for %@ %ld",aComboBox,result);
    return result;
}

-(void) showConnectionDialogFor:(VSParameter*) parameter andAvailableDevices:(NSArray*) availableDevices{
    self.parameter = parameter;
    self.availableDevices = availableDevices;
    
    
    
    
    if(self.parameter.connectedWithDeviceParameter){
        self.currentlySelectedDevice = self.parameter.deviceConnectedWith;
        [self.deviceComboBox selectItemAtIndex:[self.availableDevices indexOfObject:self.currentlySelectedDevice]];
        [self.deviceParameterComboBox selectItemAtIndex:[self.currentlySelectedDevice indexOfObjectInParameters:self.parameter.deviceParamterConnectedWith]];
    }
    else{
        self.currentlySelectedDevice = [self.availableDevices objectAtIndex:0];
        [self.deviceComboBox selectItemAtIndex:0];
        [self.deviceParameterComboBox selectItemAtIndex:0];
    }
    
    [self.deviceComboBox reloadData];
    [self.deviceParameterComboBox reloadData];
}


@end
