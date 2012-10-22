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
#import "VSExternalInput.h"


@interface VSCreateDeviceViewController ()

@property (strong) NSArray *availableParameter;

@property (strong) NSMutableArray *selectedStates;

@property (strong) NSMutableArray *ranges;

@end

@implementation VSCreateDeviceViewController

#define iIdentifier @"identifier"
#define iValue @"value"
#define iParameterType @"parameterType"
#define iDeviceTypeName @"deviceTypeName"

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
    
    
    self.availableParameter = [self availableInputParameterFromDataSource];
    [self.parameterTableView reloadData];
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
//    _parameterCount++;
//    
//    [self.parameterTableView beginUpdates];
//    [self.parameterTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_parameterCount-1]
//                                   withAnimation:NSTableViewAnimationSlideUp | NSTableViewAnimationEffectFade];
//    [self.parameterTableView endUpdates];
}


#pragma mark - NSTableViewDataSource Implementation

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.availableParameter.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    DDLogInfo(@"column: %@", [tableColumn identifier]);
    VSExternalInput *input = [self.availableParameter objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:iIdentifier]) {
        return input.identifier;
    }
    else if ([[tableColumn identifier] isEqualToString:iValue]) {
        if([input.value isKindOfClass:[NSString class]]){
            return input.value;
        }
        else if([input.value respondsToSelector:@selector(stringValue)]){
            return [input.value stringValue];
        }
        else{
            return @"invalid";
        }
    }
    else if ([[tableColumn identifier] isEqualToString:iParameterType]) {
        return input.parameterType;
    }
    else if ([[tableColumn identifier] isEqualToString:iDeviceTypeName]) {
        return input.deviceTypeName;
    }
    
    return @"Parameter";
}

#pragma mark - NSTableViewDelegate Implementation

-(BOOL) tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return YES;
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
