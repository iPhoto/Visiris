//
//  VSDeviceConfigurationViewController.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/29/12.
//
//

#import "VSDeviceConfigurationViewController.h"

#import "VSCreateDeviceViewController.h"

#import "VSExternalInputManager.h"
#import "VSDeviceManager.h"
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
        
        
        self.createDeviceViewController = [[VSCreateDeviceViewController alloc] initWithNibName:@"VSCreateDeviceViewController" bundle:nil];
        self.createDeviceViewController.delegate = self;
        
        
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
    
    /* WTF?????!!! */
    if ( ![[[self.createDeviceViewController.createDeviceWindow contentView] subviews] containsObject:self.createDeviceViewController.view] ) {
    }
    
    [[NSApplication sharedApplication] beginSheet:self.createDeviceViewController.createDeviceWindow modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}


- (void)insertNewDeviceRow
{
    _numberOfDevices++;
    [self.deviceTableView beginUpdates];
    [self.deviceTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    [self.deviceTableView endUpdates];
}


- (void)deviceCreated:(VSDevice *)device
{
    
    
    [self dismissSheetWindow];
    _isCurrentlyPresentingNewDeviceConfigurationPopover = NO;
    if (device) {
        [self.deviceManager addDevice:device];
        
        [self.deviceTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
    }
}

- (void)cancelDeviceCreation
{
    [self dismissSheetWindow];
    _isCurrentlyPresentingNewDeviceConfigurationPopover = NO;
}


- (void)dismissSheetWindow
{
    [[NSApplication sharedApplication] endSheet:self.createDeviceViewController.createDeviceWindow];
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
    return _numberOfDevices;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return @"Device";
}

@end
