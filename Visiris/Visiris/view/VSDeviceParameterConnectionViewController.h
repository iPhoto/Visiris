//
//  VSDeviceParameterConnectionViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 04.10.12.
//
//

#import <Cocoa/Cocoa.h>

@class VSParameter;
@class VSDevice;

@interface VSDeviceParameterConnectionViewController : NSViewController


#pragma mark - 
#pragma mark Properties
@property (strong) VSParameter *parameter;

@property (strong) NSArray *availableDevices;

@property (weak) NSPopover *popover;

@property (weak) IBOutlet NSPopUpButton *devicePopUpButton;
@property (weak) IBOutlet NSPopUpButton *deviceParameterPopUpButton;
@property (weak) IBOutlet NSBox *mappingHolderBox;
@property (weak) IBOutlet NSTextField *deviceNameLabel;
@property (weak) IBOutlet NSTextField *deviceParamterComboBoxLabel;
@property (weak) IBOutlet NSTextField *parameterMinValueTextField;
@property (weak) IBOutlet NSTextField *parameterMaxValueTextField;
@property (weak) IBOutlet NSTextField *deviceParameterMinValueTextField;
@property (weak) IBOutlet NSTextField *deviceParameterMaxValueTextField;
@property (weak) IBOutlet NSSlider *smoothingSlider;
@property (weak) IBOutlet NSTextField *smoothingTextField;
@property (weak) IBOutlet NSButton *toogleConnection;


#pragma mark -
#pragma mark Methods
-(void) showConnectionDialogFor:(VSParameter*) parameter andAvailableDevices:(NSArray*) availableDevices;

#pragma mark - 
#pragma mark IBAction
- (IBAction)rangeValueDidChange:(id)sender;
- (IBAction)didClickToggleConnection:(NSButton *)sender;
- (IBAction)didChangeDevicePopUpButton:(NSPopUpButton*)sender;
- (IBAction)didChangeDeviceParameterPopUpButton:(NSPopUpButton *)sender;
- (IBAction)smoothingValueDidChange:(id)sender;



@end
