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

#define PARAMETER_HOLDER_PADDING_LEFT_RIGHT 10
#define PARAMETER_TEXT_FIELD_HEIGHT 18

@synthesize nameLabel = _nameLabel;
@synthesize textValueField = _valueField;
@synthesize boolValueField = _boolValueField;
@synthesize valueSlider = _valueSlider;
@synthesize valueSliderText = _valueSliderText;
@synthesize parameterHolder = _parameterHolder;
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

-(void) awakeFromNib{
    
    if([self.view isKindOfClass:[VSParameterView class]]){
        ((VSParameterView*) self.view).viewDelegate = self;
    }
    
    [self.parameterHolder setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.parameterHolder setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.parameterHolder setAutoresizesSubviews:YES];
    
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
    [self.view setFrame:frame];
    [self.parameterHolder setFrameSize:frame.size];
    self.parameter = parameter;
    
   [self.parameter addObserver:self forKeyPath:@"defaultValue" options:0 context:nil];
     
    [self showParameter];
}

#pragma mark - Methods

-(void) saveParameterAndRemoveObserver{
    [self.parameter removeObserver:self forKeyPath:@"defaultValue"];
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

#pragma mark - VSViewDelegate Implentation

-(NSView*) nextKeyViewOfView:(NSView *)view willBeSet:(NSView *)nextKeyView{
    [self.textValueField setNextKeyView:nextKeyView];
    [self.textValueField becomeFirstResponder];
    return nextKeyView;
}

#pragma mark - NSTextViewDelegate Implementation

-(BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    if(control == self.textValueField){
        if([self respondsToSelector:self.textValueField.action]){
            [self performSelector:self.textValueField.action withObject:self.textValueField];
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
    [self.valueSlider setFloatValue:[self.parameter defaultFloatValue]];
}

- (IBAction)sliderValueHasChanged:(NSSlider *)sender {
    [self setParameterValueWithText:[sender stringValue]];
    [self.textValueField setFloatValue:[self.parameter defaultFloatValue]];
    
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
            [self.boolValueField setState:[self buttonStateOfBooleanValue:[self.parameter defaultBoolValue]]];
            break;
        case VSParameterDataTypeFloat:
            [self.valueSlider setFloatValue:[self.parameter defaultFloatValue]];
            [self.textValueField setFloatValue:[self.parameter defaultFloatValue]];
            break;
        case VSParameterDataTypeString:
            [self.textValueField setStringValue:[self.parameter defaultStringValue]];
            break;
        default:
            [self.textValueField setStringValue:[self.parameter defaultStringValue]];
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
    
    self.textValueField = [[NSTextField alloc]init];
    [self.parameterHolder addSubview:self.textValueField];
    
    [self.textValueField setFrame:NSMakeRect(PARAMETER_HOLDER_PADDING_LEFT_RIGHT, 0, 0, PARAMETER_TEXT_FIELD_HEIGHT)];
    
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.textValueField,@"textValueField", nil];
    
    NSString *constraintString = [NSString stringWithFormat:@"|-%d-[textValueField]-%d-|",PARAMETER_TEXT_FIELD_HEIGHT, PARAMETER_TEXT_FIELD_HEIGHT];
    
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary];
    
    [self.textValueField setAutoresizingMask:NSViewWidthSizable];
    [self.textValueField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.parameterHolder addConstraints:constraints];
    
    [self.textValueField setStringValue:self.parameter.defaultStringValue];
    
    [self.textValueField setTarget:self];
    [self.textValueField setAction:@selector(textValueHasChanged:)];
    
    [self.textValueField setDelegate:self];
    
    
}

/**
 * Shows paramters of the type VSParameterDataTypeBool.
 */
-(void) showBoolParameter{
    
    self.boolValueField= [[NSButton alloc]init];
    [self.boolValueField setTitle:self.parameter.name];
    [self.boolValueField setButtonType:NSSwitchButton];
    [self.boolValueField setState:[self buttonStateOfBooleanValue:self.parameter.defaultBoolValue]];
    [self.parameterHolder addSubview:self.boolValueField];
    
    [self.boolValueField setFrame:NSMakeRect(PARAMETER_HOLDER_PADDING_LEFT_RIGHT, 0, 0, PARAMETER_TEXT_FIELD_HEIGHT)];
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.boolValueField,@"boolValueField", nil];
    
    
    NSString *constraintString = [NSString stringWithFormat:@"|-%d-[boolValueField]-%d-|",PARAMETER_TEXT_FIELD_HEIGHT, PARAMETER_TEXT_FIELD_HEIGHT];
    
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary];
    
    [self.boolValueField setAutoresizingMask:NSViewWidthSizable];
    [self.boolValueField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.parameterHolder addConstraints:constraints];
    
    [self.boolValueField setTarget:self];
    [self.boolValueField setAction:@selector(boolValueHasChanged:)];
    
}

/**
 * Shows paramters of the type VSParameterDataTypeFloat.
 *
 * If hasRang of the parameter is YES a slider is shown instead of an TextField
 */
-(void) showFloatParameter{
    [self showStringParameter];
    
    if(self.parameter.hasRange){
                
        self.valueSlider = [[NSSlider alloc] init];
        [self.parameterHolder addSubview:self.valueSlider];
        
        float valueFieldWidth = 50;
        float sliderWidth = self.parameterHolder.frame.size.width - valueFieldWidth - 3*PARAMETER_HOLDER_PADDING_LEFT_RIGHT;
        [self.valueSlider setFrame:NSMakeRect(PARAMETER_HOLDER_PADDING_LEFT_RIGHT, 0, self.valueSlider.knobThickness+1,self.valueSlider.knobThickness)];
        [self.textValueField setFrame:NSMakeRect(0, 0, 0,PARAMETER_TEXT_FIELD_HEIGHT)];

        
        NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.textValueField,@"textValueField",
                                                                                    self.valueSlider,@"valueSlider",
                                                                                    nil];

        NSString *constraintString = [NSString stringWithFormat:@"|-%d-[valueSlider(>=%f)]-%d-[textValueField(==%f)]-%d-|",PARAMETER_HOLDER_PADDING_LEFT_RIGHT, self.valueSlider.knobThickness+1,PARAMETER_HOLDER_PADDING_LEFT_RIGHT,valueFieldWidth,PARAMETER_HOLDER_PADDING_LEFT_RIGHT];
        
        
        NSMutableArray* constraints = [NSMutableArray arrayWithArray: [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary]];
        
        constraintString = [NSString stringWithFormat:@"V:[valueSlider(==%f)]",self.valueSlider.knobThickness];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary]];
        
        
        [self.textValueField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.valueSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.textValueField setAutoresizingMask:NSViewNotSizable];
        [self.valueSlider setAutoresizingMask:NSViewNotSizable];

        [self.parameterHolder removeConstraints:self.parameterHolder.constraints];
        [self.parameterHolder addConstraints:constraints];
        
        [self.valueSlider setMinValue:self.parameter.rangeMinValue];
        [self.valueSlider setMaxValue:self.parameter.rangeMaxValue];
        [self.valueSlider setFloatValue:self.parameter.defaultFloatValue];
        
        [self.valueSlider setTarget:self];
        [self.valueSlider setAction:@selector(sliderValueHasChanged:)];
        
        [self.textValueField setFloatValue:self.parameter.defaultFloatValue];
        [self.textValueField setTarget:self];
        [self.textValueField setAction:@selector(valueSliderTextHasChanged:)];
        
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
