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
#import "VSExternalInputRepresentation.h"


@interface VSCreateDeviceViewController ()

@property (strong) NSArray *availableParameter;

@end

@implementation VSCreateDeviceViewController

#define iIdentifier @"identifier"
#define iValue @"value"
#define iParameterType @"parameterType"
#define iDeviceTypeName @"deviceTypeName"
#define iSelected @"selected"
#define iName @"name"
#define iMin @"rangeFrom"
#define iMax @"rangeTo"

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
    
    
    [self updateDataSource];
}

#pragma mark - IBAction

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
    [self.parameterTableView abortEditing];
    NSIndexSet *selectedParametIndizes = [self.availableParameter indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSExternalInputRepresentation class]]){
            return ((VSExternalInputRepresentation*) obj).selected;
        }
        return NO;
    }];
    
    NSArray *selectedParamters = [self.availableParameter objectsAtIndexes:selectedParametIndizes];

    BOOL result = NO;
    if([self delegateRespondsToSelector:@selector(createDeviceWithName:andParameters:)]){
        result = [self.delegate createDeviceWithName:[self.deviceNameTextField stringValue]
                              andParameters:selectedParamters];
    }
    

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
    VSExternalInputRepresentation *input = [self.availableParameter objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:iIdentifier]) {
        return input.identifier;
    }
    else if ([[tableColumn identifier] isEqualToString:iValue]) {
        if([input.value isKindOfClass:[NSNumber class]] || [input.value isKindOfClass:[NSString class]])
        return input.value;
    }
    else if ([[tableColumn identifier] isEqualToString:iSelected]) {
        return [NSNumber numberWithBool:input.selected];
    }
    else if ([[tableColumn identifier] isEqualToString:iParameterType]) {
        return input.parameterDataType;
    }
    else if ([[tableColumn identifier] isEqualToString:iDeviceTypeName]) {
        return input.deviceType;
    }
    else if ([[tableColumn identifier] isEqualToString:iName]) {
        return input.name;
    }
    else if ([[tableColumn identifier] isEqualToString:iMin]) {
        if(input.hasRange)
            return [NSNumber numberWithFloat: input.range.min];
        else{
            return @"-";
        }
    }
    else if ([[tableColumn identifier] isEqualToString:iMax]) {
        if(input.hasRange)
            return [NSNumber numberWithFloat: input.range.max];
        else{
            return @"-";
        }
    }
    
    return @"empty";
}

-(void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    VSExternalInputRepresentation *input = [self.availableParameter objectAtIndex:row];
    
    if([[tableColumn identifier] isEqualToString:iSelected]){
        if([object respondsToSelector:@selector(boolValue)]){
            input.selected = [object boolValue];
        }
    }
    else if([[tableColumn identifier] isEqualToString:iName]){
        
        
        input.name = object;
    }
    else if([[tableColumn identifier] isEqualToString:iMin]){
        VSRange newRange = VSMakeRange([object floatValue], input.range.max);
        input.range = newRange;
    }
    else if([[tableColumn identifier] isEqualToString:iMax]){
        VSRange newRange = VSMakeRange(input.range.min, [object floatValue]);
        input.range = newRange;
    }
    
}

-(BOOL) tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableColumn.identifier isEqualToString:iMin] || [tableColumn.identifier isEqualToString:iMax]){
        if(!((VSExternalInputRepresentation*)[self.availableParameter objectAtIndex:row]).hasRange){
            return NO;
        }
    }
    return YES;
}


// adding address to parameter
- (IBAction)didSelectInputAddressForParameter:(id)sender
{
    NSLog(@"add the address and update ui");
}

-(void) updateDataSource{
    self.availableParameter = [self availableInputParameterFromDataSource];
    
    [self.parameterTableView reloadData];
    
    if (!self.availableParameter) {
        DDLogError(@"DataSource did not deliver a valid input parameter array");
    }
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

#pragma mark - Methods

-(void) dataSourceWasChanged{
    [self updateDataSource];
    [self.parameterTableView reloadData];
}

-(void) reset{
    [self.deviceNameTextField setStringValue:@""];
    [self updateDataSource];
}

#pragma mark - Private Methods

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.delegate){
        if([self.delegate conformsToProtocol:@protocol(VSCreateDeviceViewControllerDelegate)]){
            if([self.delegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}
@end
