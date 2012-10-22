//
//  VSCreateDeviceViewController.m
//  Visiris
//
//  Created by Andreas Schacherbauer on 9/30/12.
//
//

#import "VSCreateDeviceViewController.h"

#import "VSCoreServices.h"
#import "VSOSCPort.h"
#import "VSDevice.h"



@interface VSCreateDeviceViewController ()
{
    int                                         _parameterCount;
}



@end

@implementation VSCreateDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //
    _parameterCount = 0;
    
    
    self.availableParameter = [self availableInputParameterFromDataSource];
    
    if (!self.availableParameter) {
        DDLogError(@"DataSource did not deliver a valid input parameter array");
    }
}


- (IBAction)didPressAddParameterButton:(NSButton *)button
{
    [self addNewParameter];
}

- (IBAction)didPressCancelDeviceCreationButton:(NSButton *)button
{
    [self signalDelegateThatDeviceCreationWasCancelled];
}


- (IBAction)didPressCreateDeviceButton:(NSButton *)button
{
    [self signalDelegateThatDeviceWasCreated:[[VSDevice alloc] init]];
}

#pragma mark - Parameter creation
- (void)addNewParameter
{
    _parameterCount++;
    
    [self.parameterTableView beginUpdates];
    [self.parameterTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_parameterCount-1]
                                   withAnimation:NSTableViewAnimationSlideUp | NSTableViewAnimationEffectFade];
    [self.parameterTableView endUpdates];
}


#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _parameterCount;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    if ([[tableColumn identifier] isEqualToString:@"Address"]) {
        NSPopUpButtonCell *cell = [tableColumn dataCellForRow:row];
        [[cell menu] setDelegate:self];
        [[cell menuItem]setAction:@selector(didSelectInputAddressForParameter:)];
        
        VSOSCPort *port = [self.availableParameter objectAtIndex:0];
        [cell addItemsWithTitles:port.addresses];
    }
    return @"Parameter";
}


// adding address to parameter
- (IBAction)didSelectInputAddressForParameter:(id)sender
{
    NSLog(@"add the address and update ui");
}


#pragma mark - DataSource Communication
- (NSArray *)availableInputParameterFromDataSource
{
    NSArray *availableInputParameter = nil;
    
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(availableInputParameter)]) {
            availableInputParameter = [self.dataSource availableInputParameter];
        }
    }
    
    return availableInputParameter;
}

#pragma mark - Delegate Communication
- (void)signalDelegateThatDeviceCreationWasCancelled
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didCancelDeviceCreation)]) {
            [self.delegate didCancelDeviceCreation];
        }
    }
}

- (void)signalDelegateThatDeviceWasCreated:(VSDevice *)newDevice
{
    if (newDevice) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didCreatedDevice:)]) {
                [self.delegate didCreatedDevice:newDevice];
            }
        }
    }
}

@end
