//
//  VSCreateDeviceViewController.h
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import <Cocoa/Cocoa.h>


@class VSDevice;

@protocol VSCreateDeviceViewControllerDataSource <NSObject>

- (NSArray *)availableInputParameter;

@end

@protocol VSCreateDeviceViewControllerDelegate <NSObject>

- (void)didCancelDeviceCreation;
- (BOOL) createDeviceWithName:(NSString*) deviceName andParameters:(NSArray*) parameters;

@end


@interface VSCreateDeviceViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>

@property (weak) IBOutlet NSBox                                             *parameterBox;
@property (weak) IBOutlet NSButton                                          *addParameterButton;
@property (weak) IBOutlet NSTableView                                       *parameterTableView;
@property (weak) IBOutlet NSTextField *deviceNameTextField;

@property (weak) IBOutlet NSButton                                          *cancelDeviceCreationButton;
@property (weak) IBOutlet NSButton                                          *createDeviceButton;

@property (strong) IBOutlet NSWindow                                        *createDeviceWindow;


@property (weak) id<VSCreateDeviceViewControllerDataSource>                 dataSource;
@property (weak) id<VSCreateDeviceViewControllerDelegate>                   delegate;



#pragma mark - IBActions
// adding new parameter
- (IBAction)didPressAddParameterButton:(NSButton *)button;

// popover lifecycle
- (IBAction)didPressCancelDeviceCreationButton:(NSButton *)button;
- (IBAction)didPressCreateDeviceButton:(NSButton *)button;

// parameter creation
- (IBAction)didSelectInputAddressForParameter:(id)sender;

#pragma mark -Methods

-(void) dataSourceWasChanged;

-(void) reset;

@end
