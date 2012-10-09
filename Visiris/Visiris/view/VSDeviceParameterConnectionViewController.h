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

@interface VSDeviceParameterConnectionViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>

@property (strong) VSParameter *parameter;

@property (strong) NSArray *availableDevices;

@property (weak) IBOutlet NSButton *toogleConnection;

- (IBAction)rangeValueDidChange:(id)sender;

- (IBAction)didClickToggleConnection:(NSButton *)sender;
@property (weak) IBOutlet NSPopUpButton *devicePopUpButton;
@property (weak) IBOutlet NSPopUpButton *deviceParameterPopUpButton;
- (IBAction)didChangeDevicePopUpButton:(NSPopUpButton*)sender;
- (IBAction)didChangeDeviceParameterPopUpButton:(NSPopUpButton *)sender;


@property (weak) IBOutlet NSTextField *deviceNameLabel;
@property (weak) IBOutlet NSComboBox *deviceParameterComboBox;
@property (weak) IBOutlet NSTextField *deviceParamterComboBoxLabel;
@property (weak) IBOutlet NSComboBox *deviceComboBox;
@property (weak) IBOutlet NSTextField *parameterMinValueTextField;
@property (weak) IBOutlet NSTextField *parameterMaxValueTextField;
@property (weak) IBOutlet NSTextField *deviceParameterMinValueTextField;
@property (weak) IBOutlet NSTextField *deviceParameterMaxValueTextField;
@property (weak) NSPopover *popover;
-(void) showConnectionDialogFor:(VSParameter*) parameter andAvailableDevices:(NSArray*) availableDevices;

@end
