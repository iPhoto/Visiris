//
//  VSDeviceConfigurationViewController.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/29/12.
//
//

#import "VSDeviceConfigurationViewController.h"

#import "VSExternalInputManager.h"
#import "VSDeviceManager.h"
#import "VSDevice.h"

#import "VSCoreServices.h"

@interface VSDeviceConfigurationViewController ()
{
    int                                                 _numberOfDevices;
    BOOL                                                _isCurrentlyPresentingNewDeviceConfigurationPopover;
}

/** VSExternalInputManager is initialized by VSDocument */
@property (strong) VSExternalInputManager*              externalInputManager;
@property (strong) VSDeviceManager*                     deviceManager;

@end


/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSDeviceConfigurationViewController";

@implementation VSDeviceConfigurationViewController

- (id)initWithDefaultNib
{
    self = [self initWithNibName:defaultNib bundle:nil];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _numberOfDevices = 0;
        
        _isCurrentlyPresentingNewDeviceConfigurationPopover = NO;
        
        // Start searching for external input devices
        self.externalInputManager = [[VSExternalInputManager alloc] init];
        
        // Create DeviceManager
        self.deviceManager = [[VSDeviceManager alloc] init];
        
    }
    
    return self;
}


#pragma mark - Device Management
- (IBAction)didPressAddDeviceButton:(NSButton *)addButton
{
    if ( !_isCurrentlyPresentingNewDeviceConfigurationPopover ) {
        
        [self insertNewDeviceRowAndPresentDeviceConfigurationSheet];
//        [self insertNewDeviceRowAndPresentDeviceConfigurationPopover];
    }
}

- (void)insertNewDeviceRowAndPresentDeviceConfigurationSheet
{
    [self insertNewDeviceRow];
    
    [[NSApplication sharedApplication] beginSheet:self.createDeviceViewController.createDeviceWindow modalForWindow:[NSApp keyWindow] modalDelegate:nil didEndSelector:@selector(didFinishCreatingNewInputDeviceFromSheet:) contextInfo:nil];
}


- (void)insertNewDeviceRow
{
    _numberOfDevices++;
    [self.deviceTableView beginUpdates];
    [self.deviceTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    [self.deviceTableView endUpdates];
}


- (void)didFinishCreatingNewInputDeviceFromSheet:(id)sender
{

}

- (void)deviceCreated:(VSDevice *)device
{
    _isCurrentlyPresentingNewDeviceConfigurationPopover = NO;
    if (device) {
        [self.deviceManager addDevice:device];
        
        [self.deviceTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
    }
}

- (void)cancelDeviceCreation
{
    
    _isCurrentlyPresentingNewDeviceConfigurationPopover = NO;

}


#pragma mark - VSCreateDeviceViewControllerDelegate
- (void)didCancelDeviceCreation
{
    [self cancelDeviceCreation];
}


- (void)didCreatedDevice:(VSDevice *)device
{
    if (device) {
        [self deviceCreated:device];
    }
}

#pragma mark - VSCreateDeviceViewControllerDataSource
- (NSArray *)availableInputParameter
{
    return [self.externalInputManager availableInputs];
}


#pragma mark - NSTableViewDelegate

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.deviceManager.devices.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([tableColumn.identifier isEqualToString:@"name"]){
        return [self.deviceManager objectInDevicesAtIndex:row].name;
    }
    else if([tableColumn.identifier isEqualToString:@"id"]){
        return [self.deviceManager objectInDevicesAtIndex:row].ID;
    }
    else{
        return nil;
    }
}

@end
