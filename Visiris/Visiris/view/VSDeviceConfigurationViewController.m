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
#import "VSDevice.h"
#import "VSDeviceRepresentation.h"
#import "VSDocument.h"

#import "VSCoreServices.h"
#import "VSExternalInput.h"

@interface VSDeviceConfigurationViewController ()
{
    int                                                 _numberOfDevices;
    BOOL                                                _isCurrentlyPresentingNewDeviceConfigurationPopover;
}

/** VSExternalInputManager is initialized by VSDocument */
//@property (strong) VSExternalInputManager*              externalInputManager;
@property (weak) VSDeviceManager*                     deviceManager;

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
        self.createDeviceViewController.dataSource = self;
    }
    
    return self;
}


-(void) awakeFromNib{
    // Create DeviceManager
    self.deviceManager =  ((VSDocument*)[[NSDocumentController sharedDocumentController] currentDocument]).deviceManager;
}

#pragma mark - Device Management
- (IBAction)didPressAddDeviceButton:(NSButton *)addButton
{
    NSLog(@"Available Inputs");
    
    for (VSExternalInput *input in [self.deviceManager availableInputs]) {
        NSLog(@"ParameterType: %@   Identifier: %@", input.parameterTypeName, input.identifier);
    }
    
    if ( !_isCurrentlyPresentingNewDeviceConfigurationPopover ) {
        
        [self insertNewDeviceRowAndPresentDeviceConfigurationSheet];
    }
}

- (void)insertNewDeviceRowAndPresentDeviceConfigurationSheet
{
  //  [self insertNewDeviceRow];
    
    if ( ![[[self.createDeviceViewController.createDeviceWindow contentView] subviews] containsObject:self.createDeviceViewController.view] ) {
    }
    
    [[NSApplication sharedApplication] beginSheet:self.createDeviceViewController.createDeviceWindow
                                   modalForWindow:[NSApp keyWindow]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
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
        [self.deviceManager addDevicesObject:device];
        
        [self.deviceTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0]
                                        columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
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


#pragma mark - VSCreateDeviceViewControllerDelegate Implementation
- (void)didCancelDeviceCreation
{
    [self cancelDeviceCreation];
}


- (BOOL) createDeviceWithName:(NSString *)deviceName andParameters:(NSArray *)parameters{
    BOOL result = [self.deviceManager createDeviceWithName:deviceName andParameters:parameters];
    
    if(result){
        [self.deviceTableView reloadData];
        [[NSApplication sharedApplication] endSheet:self.createDeviceViewController.createDeviceWindow];
    }
    
    return result;
}

#pragma mark - VSCreateDeviceViewControllerDataSource Implementation
- (NSArray *)availableInputParameter
{
    return self.deviceManager.availableInputRepresentation;
}


#pragma mark - NSTableViewDelegate Implementation

-(id<NSPasteboardWriting>) tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row{
    return [self.deviceManager objectInDeviceRepresentationsAtIndex:row];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.deviceManager.deviceRepresentations.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([tableColumn.identifier isEqualToString:@"name"]){
        return [self.deviceManager objectInDeviceRepresentationsAtIndex:row].name;
    }
    else if([tableColumn.identifier isEqualToString:@"id"]){
        return [self.deviceManager objectInDeviceRepresentationsAtIndex:row].ID;
    }
    else{
        return nil;
    }
}

@end
