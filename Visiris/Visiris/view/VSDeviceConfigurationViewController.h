//
//  VSDeviceConfigurationViewController.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/29/12.
//
//

#import <Cocoa/Cocoa.h>

#import "VSCreateDeviceViewController.h"

@interface VSDeviceConfigurationViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate, VSCreateDeviceViewControllerDelegate, VSCreateDeviceViewControllerDataSource>

@property (weak) IBOutlet NSButton                                              *addDeviceButton;
@property (weak) IBOutlet NSTableView                                           *deviceTableView;

@property (strong) IBOutlet NSPopover                                           *createDevicePopover;
@property (strong) IBOutlet NSWindow                                            *createDeviceDetailWindow;

@property (strong) IBOutlet VSCreateDeviceViewController                        *createDeviceViewController;


/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;


- (IBAction)didPressAddDeviceButton:(NSButton *)addButton;

@end
