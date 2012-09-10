//
//  VSParameterViewController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSParameterViewController.h"

#import "VSParameterView.h"
#import "VSParameter.h"
#import "VSAnimation.h"

#import "VSCoreServices.h"

@interface VSParameterViewController ()


/** VSParemter the view displayes. */
@property VSParameter *parameter;



@end

@implementation VSParameterViewController

#define PARAMETER_WITH_RANGE_TEXT_FIELD_WIDTH 50
#define VALUE_SLIDER_MINIMUM_WIDTH 50

@synthesize nameLabel           = _nameLabel;
@synthesize textField           = _valueField;
@synthesize checkBox            = _boolValueField;
@synthesize horizontalSlider    = _valueSlider;
@synthesize parameterHolder     = _parameterHolder;
@synthesize parameter           = _parameter;

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

-(void) awakeFromNib{
    
    if([self.view isKindOfClass:[VSParameterView class]]){
        ((VSParameterView*) self.view).viewDelegate = self;
    }
    [self.view setAutoresizingMask:NSViewWidthSizable];
    [_parameter addObserver:self forKeyPath:@"defaultValue" options:0 context:nil];
}


#pragma mark - NSViewController

//TODO: change only the value
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //observers if the defaultValue of the parameter has changed
    if([keyPath isEqualToString:@"defaultValue"]){
        [self updateParameterValue];
    }
}

-(void) showParameter:(VSParameter *)parameter inFrame:(NSRect)frame{
    
    self.parameter = parameter;
    [self.parameter addObserver:self forKeyPath:@"defaultValue" options:0 context:nil];
    
    [self showParameter];
}

#pragma mark - Methods

-(void) saveParameterAndRemoveObserver{
    [self.parameter removeObserver:self forKeyPath:@"defaultValue"];
    switch (self.parameter.dataType) {
        case VSParameterDataTypeBool:
            [self setParametersDefaultBoolValue:[self boolValueForButtonState:self.checkBox.state]];
            break;
        case VSParameterDataTypeFloat:
        {
            [self setParametersDefaultFloatValue:[self.textField floatValue]];
            break;
        }
        case VSParameterDataTypeString:
            [self setParametersDefaultStringValue:[self.textField stringValue]];
            break;
        default:
            [self setParametersDefaultStringValue:[self.textField stringValue]];
            break;
    }
}

#pragma mark - VSViewDelegate Implentation

-(NSView*) nextKeyViewOfView:(NSView *)view willBeSet:(NSView *)nextKeyView{
    [self.textField setNextKeyView:nextKeyView];
    [self.textField becomeFirstResponder];
    return nextKeyView;
}

#pragma mark - NSTextViewDelegate Implementation

-(BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    if(control == self.textField){
        if(self.textField.action){
            if([self respondsToSelector:control.action]){
                [self performSelector:control.action withObject:control];
            }
        }
    }
    
    return YES;
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
    [self.horizontalSlider setFloatValue:[self.parameter defaultFloatValue]];
}

- (IBAction)sliderValueHasChanged:(NSSlider *)sender {
    [self setParameterValueWithText:[sender stringValue]];
    [self.textField setFloatValue:[self.parameter defaultFloatValue]];
    
}



#pragma mark - Private Methods

#pragma mark - Show Parameter

/**
 * Shows the parameter stored in the parameter property according to its VSParameterDataType
 */
-(void) updateParameterValue{
    [self.nameLabel setStringValue: NSLocalizedString(self.parameter.name, @"")];
    
    switch (self.parameter.dataType) {
        case VSParameterDataTypeBool:
            [self.checkBox setState:[self buttonStateOfBooleanValue:[self.parameter defaultBoolValue]]];
            break;
        case VSParameterDataTypeFloat:
            [self.horizontalSlider setFloatValue:[self.parameter defaultFloatValue]];
            [self.textField setFloatValue:[self.parameter defaultFloatValue]];
            break;
        case VSParameterDataTypeString:
            [self.textField setStringValue:[self.parameter defaultStringValue]];
            break;
        default:
            [self.textField setStringValue:[self.parameter defaultStringValue]];
            break;
    }
}

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
    [self.parameterHolder removeConstraints:self.parameterHolder.constraints];
    
    self.textField = [[NSTextField alloc]init];
    [self.parameterHolder addSubview:self.textField];
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.textField setFrameSize:self.textField.intrinsicContentSize];
    
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.textField,@"textValueField", nil];
    
    NSString *constraintString = [NSString stringWithFormat:@"|[textValueField]|"];
    
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary];
    
    [self.parameterHolder removeConstraints:self.parameterHolder.constraints];
    
    [self.parameterHolder addConstraints:constraints];
    
    [self.textField setStringValue:self.parameter.defaultStringValue];
    [self.textField setTarget:self];
    [self.textField setAction:@selector(textValueHasChanged:)];
    
    [self.textField setDelegate:self];
    
    
}

/**
 * Shows paramters of the type VSParameterDataTypeBool.
 */
-(void) showBoolParameter{
    
    self.checkBox= [[NSButton alloc]init];
    [self.checkBox setTitle:self.parameter.name];
    [self.checkBox setButtonType:NSSwitchButton];
    [self.checkBox setState:[self buttonStateOfBooleanValue:self.parameter.defaultBoolValue]];
    [self.parameterHolder addSubview:self.checkBox];
    
    
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.checkBox,@"boolValueField", nil];
    NSString *constraintString = [NSString stringWithFormat:@"|-[boolValueField]-|"];
    
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary];
    
    [self.checkBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.parameterHolder addConstraints:constraints];
    
    [self.checkBox setTarget:self];
    [self.checkBox setAction:@selector(boolValueHasChanged:)];
    
}

/**
 * Shows paramters of the type VSParameterDataTypeFloat.
 *
 * If hasRang of the parameter is YES a slider is shown instead of an TextField
 */
-(void) showFloatParameter{
    [self showStringParameter];
    
    [self.textField setFloatValue:self.parameter.defaultFloatValue];
    [self.textField setTarget:self];
    [self.textField setAction:@selector(valueSliderTextHasChanged:)];
    
    if(self.parameter.hasRange){
        self.horizontalSlider = [[NSSlider alloc] init];
        self.horizontalSlider.identifier = @"valueSlider";
        
        [self.parameterHolder addSubview:self.horizontalSlider];
        
        [self.horizontalSlider setFrameSize:self.horizontalSlider.intrinsicContentSize];
        
        [self initValueSlider];
        
        [self setConstraintsForParameterWithRange];
    }
    
}

-(void) setConstraintsForParameterWithRange{
    [self.horizontalSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     self.textField,@"textValueField",
                                     self.horizontalSlider,@"valueSlider",
                                     nil];
    
    NSString *constraintString = [NSString stringWithFormat: @"|-[valueSlider(>=%d)]-[textValueField(==%d)]-|", VALUE_SLIDER_MINIMUM_WIDTH, PARAMETER_WITH_RANGE_TEXT_FIELD_WIDTH];
    
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:  NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    
    [self.parameterHolder removeConstraints:self.parameterHolder.constraints];
    [self.parameterHolder addConstraints:constraints];
}

-(void) initValueSlider{
    [self.horizontalSlider setMinValue:self.parameter.rangeMinValue];
    [self.horizontalSlider setMaxValue:self.parameter.rangeMaxValue];
    [self.horizontalSlider setFloatValue:self.parameter.defaultFloatValue];
    
    [self.horizontalSlider setTarget:self];
    [self.horizontalSlider setAction:@selector(sliderValueHasChanged:)];
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
    if(self.parameter.defaultFloatValue != aFloatValue){
        
        [self registerDefaultValueUndo];
        [self.parameter setDefaultFloatValue:aFloatValue];
    }
}

/**
 * Sets the default value of the VSParamter and registers it for undoing
 */
-(void) registerDefaultValueUndo{
    [self.parameter undoParametersDefaultValueChange:self.parameter.defaultValue atUndoManager:self.view.undoManager];
}

/**
 * Sets the given value as the parameter's defaultStringValue and registers the change at the view's undoManager
 * @param aStringValue Value to be set as the parameter's default value.
 */
-(void) setParametersDefaultStringValue:(NSString*) aStringValue{
    if(![self.parameter.defaultStringValue isEqualToString:aStringValue]){
        [self registerDefaultValueUndo];
        
        [self.parameter setDefaultStringValue:aStringValue];
    }
}

/**
 * Sets the given value as the parameter's defaultBoolValue and registers the change at the view's undoManager
 * @param aBoolValue Value to be set as the parameter's default value.
 */
-(void) setParametersDefaultBoolValue:(BOOL) aBoolValue{
    if(self.parameter.defaultBoolValue != aBoolValue){
        [self registerDefaultValueUndo];
        
        [self.parameter setDefaultBoolValue:aBoolValue];
    }
}

@end
