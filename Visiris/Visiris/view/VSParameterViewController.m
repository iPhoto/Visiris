//
//  VSParameterViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameterViewController.h"
#import "VSParameter.h"
#import "VSAnimation.h"

@interface VSParameterViewController ()

@end

@implementation VSParameterViewController
@synthesize nameLabel = _nameLabel;
@synthesize textValueField = _valueField;
@synthesize boolValueField = _boolValueField;
@synthesize valueSlider = _valueSlider;
@synthesize valueSliderText = _valueSliderText;
@synthesize parameter = _parameter;

/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSParameterView";



#pragma mark - Init

-(id) initWithDefaultNib{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - NSViewController

//TODO: change only the value
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //observers if the defaultValue of the parameter has changed
    if([keyPath isEqualToString:@"defaultValue"]){
        [self showParameter];
    }
}

#pragma mark - Methods

-(void) saveParameterAndRemoveObserver{
    [self.parameter.animation removeObserver:self forKeyPath:@"defaultValue"];
    switch (self.parameter.dataType) {
        case VSParameterDataTypeBool:
            [self setParametersDefaultBoolValue:[self boolValueForButtonState:self.boolValueField.state]];
            break;
        case VSParameterDataTypeFloat:
        {
            if (!self.parameter.hasRange) {
                [self setParametersDefaultFloatValue:[self.textValueField floatValue]];
            }
            else {
                [self setParametersDefaultFloatValue:[self.valueSliderText floatValue ]];
            }
            break;
        }
        case VSParameterDataTypeString:
            [self setParametersDefaultStringValue:[self.textValueField stringValue]];
            break;
        default:
            [self setParametersDefaultStringValue:[self.textValueField stringValue]];
            break;
    }
}

#pragma mark - IBActions

- (IBAction)textValueHasChanged:(id)sender {
    [self setParameterValueWithText:[sender stringValue]];
}

- (IBAction)boolValueHasChanged:(NSButton *)sender {
    
    [self setParametersDefaultBoolValue:[self boolValueForButtonState:sender.state]];
}

- (IBAction)valueSliderTextHasChanged:(NSTextField *)sender {
    [self setParameterValueWithText:[sender stringValue]];
    [self.valueSlider setFloatValue:[self.parameter.animation defaultFloatValue]];
}

- (IBAction)sliderValueHasChanged:(NSSlider *)sender {
    [self setParameterValueWithText:[sender stringValue]];
    [self.valueSliderText setFloatValue:[self.parameter.animation defaultFloatValue]];

}



#pragma mark - Private Methods

#pragma mark - Show Parameter

/**
 * Shows the parameter stored in the parameter property according to its VSParameterDataType
 */
-(void) showParameter{
    [self.nameLabel setStringValue: NSLocalizedString(self.parameter.name, @"")];
    
    switch (self.parameter.dataType) {
        case VSParameterDataTypeBool:
            [self showBoolParameter];
            break;
        case VSParameterDataTypeFloat:
            [self showFloatParameter];
            break;
        case VSParameterDataTypeString:
            [self showStringParameter];
            break;
        default:
            [self showStringParameter];
            break;
    }
}

/**
 * Shows paramters of the type VSParameterDataTypeString.
 */
-(void) showStringParameter{
    
    
    [self.textValueField setHidden:NO];
    [self.boolValueField setHidden:YES];
    [self.valueSlider setHidden:YES];
    [self.valueSliderText setHidden:YES];
    [self.textValueField setStringValue:self.parameter.animation.defaultStringValue];
}

/**
 * Shows paramters of the type VSParameterDataTypeBool.
 */
-(void) showBoolParameter{
    [self.textValueField setHidden:YES];
    [self.boolValueField setHidden:NO];
    [self.valueSlider setHidden:YES];
    [self.valueSliderText setHidden:YES];
    [self.boolValueField setState:[self buttonStateOfBooleanValue:self.parameter.animation.defaultBoolValue]];
}

/**
 * Shows paramters of the type VSParameterDataTypeFloat.
 *
 * If hasRang of the parameter is YES a slider is shown instead of an TextField
 */
-(void) showFloatParameter{
    
    if(self.parameter.hasRange){
        [self.textValueField setHidden:YES];
        [self.boolValueField setHidden:YES];
        [self.valueSlider setHidden:NO];
        [self.valueSliderText setHidden:NO];
        
        [self.valueSlider setMinValue:self.parameter.rangeMinValue];
        [self.valueSlider setMaxValue:self.parameter.rangeMaxValue];
        [self.valueSlider setFloatValue:self.parameter.animation.defaultFloatValue];
        
        [self.valueSliderText setFloatValue:self.parameter.animation.defaultFloatValue];
    }
    else {
        [self.textValueField setHidden:NO];
        [self.boolValueField setHidden:YES];
        [self.valueSlider setHidden:YES];
        [self.valueSliderText setHidden:YES];
        [self.textValueField setFloatValue:self.parameter.animation.defaultFloatValue];
    }
    
}

/**
 * Returns the NSButtonState according to the given value.
 * @param value Bool value the correlating button state will be returned for.
 * @return NSOnState if the given value is YES, NSOffState otherwise
 */
-(NSInteger) buttonStateOfBooleanValue:(BOOL) value{
    if (value) {
        return NSOnState;
    }
    else {
        return NSOffState;
    }
}


#pragma mark - Set Parameter

/**
 * Returns the correlating bool value of the given button state.
 * @param state Button state the correlating bool value is returned for.
 * @return YES if the given state is NSOnState, NO otherwise
 */
-(BOOL) boolValueForButtonState:(NSInteger) state{
    if (state == NSOnState) {
        return YES;
    }
    else {
        return NO;
    }
}

/**
 * Sets the given string as defaultValue of the parameter.
 *
 * The string is converted according to the parameterType of the paramter
 * @param aString NSString to be set as defaultValue of the parameter
 */
-(void) setParameterValueWithText:(NSString*) aString{
    
    switch (self.parameter.dataType) {
        case VSParameterDataTypeFloat:
            [self setParametersDefaultFloatValue:[aString floatValue]];
            break;
            
        case VSParameterDataTypeString:
            [self setParametersDefaultStringValue:aString];
            break;
            
        default:
            break;
    }
}

/**
 * Sets the given value as the parameter's defaultFloatValue and registers the change at the view's undoManager
 * @param aFloatValue Value to be set as the parameter's default value.
 */
-(void) setParametersDefaultFloatValue:(float) aFloatValue{
    if(self.parameter.animation.defaultFloatValue != aFloatValue){
        
        [self registerDefaultValueUndo];
        [self.parameter.animation setDefaultFloatValue:aFloatValue];
    }
}

/**
 * Sets the default value of the VSParamter and registers it for undoing
 */
-(void) registerDefaultValueUndo{
    [self.parameter.animation undoParametersDefaultValueChange:self.parameter.animation.defaultValue atUndoManager:self.view.undoManager];
}

/**
 * Sets the given value as the parameter's defaultStringValue and registers the change at the view's undoManager
 * @param aStringValue Value to be set as the parameter's default value.
 */
-(void) setParametersDefaultStringValue:(NSString*) aStringValue{
    if(![self.parameter.animation.defaultStringValue isEqualToString:aStringValue]){
        [self registerDefaultValueUndo];
        
        [self.parameter.animation setDefaultStringValue:aStringValue];
    }
}

/**
 * Sets the given value as the parameter's defaultBoolValue and registers the change at the view's undoManager
 * @param aBoolValue Value to be set as the parameter's default value.
 */
-(void) setParametersDefaultBoolValue:(BOOL) aBoolValue{
    if(self.parameter.animation.defaultBoolValue != aBoolValue){
        [self registerDefaultValueUndo];
        
        [self.parameter.animation setDefaultBoolValue:aBoolValue];
    }
}


#pragma mark - Properties


-(VSParameter*) parameter{
    return _parameter;
}


-(void) setParameter:(VSParameter *)parameter{
    if(parameter != _parameter){
        
        _parameter = parameter;
        
        [_parameter.animation addObserver:self forKeyPath:@"defaultValue" options:0 context:nil];
        
        [self showParameter];
    }
}
@end
