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
#import "VSOptionParameter.h"
#import "VSAnimation.h"
#import "VSKeyFrame.h"
#import "VSDevice.h"
#import "VSDeviceParameterConnectionViewController.h"

#import "VSCoreServices.h"


@interface VSParameterViewController ()

/** VSParemteer the view displayes. */
@property (weak) VSParameter *parameter;

/** Background-color of the view */
@property (strong) NSColor *color;

@property (strong) NSMutableDictionary *deviceConnectors;

@property (strong) NSMutableDictionary *availableDevies;

@property (strong) NSPopover *deviceParameterConnectingPopOver;

@end



@implementation VSParameterViewController

#define PARAMETER_WITH_RANGE_TEXT_FIELD_WIDTH 50
#define VALUE_SLIDER_MINIMUM_WIDTH 50


/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSParameterView";


#pragma mark - Init

-(id) initWithDefaultNibAndBackgroundColor:(NSColor*) color{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        self.color = color;
        self.deviceConnectors = [[NSMutableDictionary alloc] init];
        self.availableDevies = [[NSMutableDictionary alloc]init];
        if([self.view isKindOfClass:[VSParameterView class]]){
            ((VSParameterView*) self.view).fillColor = self.color;
        }
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
        //        ((VSParameterView*) self.view).viewDelegate = self;
    }
    [self.view setAutoresizingMask:NSViewWidthSizable];
}


#pragma mark - NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //observers if the defaultValue of the parameter has changed
    if([keyPath isEqualToString:@"currentValue"]){
        [self updateParameterValue];
    }
}

#pragma mark - Methods

-(void) removeObservers{
    [self.parameter removeObserver:self forKeyPath:@"currentValue"];
}

-(void) showParameter:(VSParameter *)parameter andAvailableDevices:(NSArray*) availableDevices{
    
    self.parameter = parameter;
    
    [self.parameter addObserver:self forKeyPath:@"currentValue" options:0 context:nil];
    
    [self.nameLabel setStringValue: NSLocalizedString(self.parameter.name, @"")];
    
    if([self.parameter isKindOfClass:[VSOptionParameter class]]){
        [self showOptionParameter];
    }
    else{
        [self showParameter];
    }
    
    for(VSDevice *device in availableDevices){
        [self addDeviceConnectorForDevice:device];
    }
}

#pragma mark - Devices

-(void) addDeviceConnectorForDevice:(VSDevice*) device{
    NSButton *deviceConnector = [[NSButton alloc]initWithFrame:NSMakeRect(0, 0, 20, self.deviceConnectorsHolder.frame.size.height)];
    
    deviceConnector.identifier = device.ID;
    [deviceConnector setStringValue:device.name];
    [deviceConnector setAction:@selector(toggleParameterDeviceConnection:)];
    [deviceConnector setTarget:self];
    
    [self.deviceConnectorsHolder addSubview:deviceConnector];
    
    [self.deviceConnectors setObject:deviceConnector
                              forKey:device.ID];
    
    [self.availableDevies setObject:device
                             forKey:device.ID];
}

-(void) removeDeviceconnectorForDevice:(VSDevice *)device{
    NSButton *buttonToRemove = [self.deviceConnectors objectForKey:device.ID];
    
    [buttonToRemove removeFromSuperview];
    
    [self.availableDevies removeObjectForKey:device.ID];
    [self.deviceConnectors removeObjectForKey:device.ID];
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
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:control.action withObject:control];
                #pragma clang diagnostic pop
            }
        }
    }
    
    return YES;
}

#pragma mark - NSComboBoxDelegate Implementation

-(void) comboBoxWillDismiss:(NSNotification *)notification{
    [self storeParameterValue];
}

#pragma mark - IBActions

- (IBAction)textValueHasChanged:(id)sender {
    [self storeParameterValue];
}
 
- (IBAction)boolValueHasChanged:(NSButton *)sender {
    [self storeParameterValue];
}

- (IBAction)valueSliderTextHasChanged:(NSTextField *)sender {
    [self storeParameterValue];
}

- (IBAction)sliderValueHasChanged:(NSSlider *)sender {
    [self.textField setFloatValue:sender.floatValue];
    [self storeParameterValue];
}

- (IBAction)keyFrameButton:(id)sender {
    [self addNewKeyFrame];
}

- (IBAction)previousKeyFrame:(id)sender {
    if([self keyFrameDelegateRespondsToSelector:@selector(parameterViewController:wantsToGoToPreviousFrameOfParameter:)]){
        [self.keyFrameDelegate parameterViewController:self
           wantsPlayheadToGoToPreviousFrameOfParameter:self.parameter];
    }
}

- (IBAction)nextKeyFrame:(id)sender {
    if([self keyFrameDelegateRespondsToSelector:@selector(parameterViewController:wantsToGoToNextKeyFrameOfParameter:)]){
        [self.keyFrameDelegate parameterViewController:self
            wantsPlayheadToGoToNextKeyFrameOfParameter:self.parameter];
    }
}

- (IBAction)toggleParameterDeviceConnection:(id)sender {
    if([sender isKindOfClass:[NSControl class]]){
        NSString *deviceID =  ((NSControl*)sender).identifier;
        
        VSDevice *deviceToConnect = [self.availableDevies objectForKey:deviceID];
        
        if(deviceToConnect){
            [self showDeviceParameterConnectionDialogForDevice:deviceToConnect
                                                relativeToView:((NSView*)sender)];
        }
    }
}

-(void) showDeviceParameterConnectionDialogForDevice:(VSDevice*)device relativeToView:(NSView*)relativeToView{
        self.deviceParameterConnectingPopOver  = [[NSPopover alloc] init];
        
    [self.deviceParameterConnectionPopoverViewController showConnectionDialogFor:self.parameter andAvailableDevices:[self.availableDevies allValues]];
    
    self.deviceParameterConnectingPopOver.contentViewController = self.deviceParameterConnectionPopoverViewController;
    
        self.deviceParameterConnectingPopOver.behavior = NSPopoverBehaviorTransient;
        
        // so we can be notified when the popover appears or closes
        self.deviceParameterConnectingPopOver.delegate = self;
    
    [self.deviceParameterConnectingPopOver showRelativeToRect:relativeToView.frame ofView:relativeToView preferredEdge:NSMaxYEdge];
}


#pragma mark - Private Methods

/**
 * Checks if the delegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) keyFrameDelegateRespondsToSelector:(SEL) selector{
    if(self.keyFrameDelegate != nil){
        if([self.keyFrameDelegate conformsToProtocol:@protocol(VSParameterViewKeyFrameDelegate) ]){
            if([self.keyFrameDelegate respondsToSelector: selector]){
                return YES;
            }
        }
    }
    
    return NO;
}

/**
 * Tells the keyFrameDelegate to create a new keyFrame with the currentParameterValue
 *
 * if selectedKeyFrame is set its value is changed instead of creating a new Keyframe.
 */
-(void) addNewKeyFrame{
    if(!self.selectedKeyframe){
        if([self keyFrameDelegateRespondsToSelector:@selector(addKeyFrameToParameter:withValue:)]){
            VSKeyFrame *newKeyFrame = [self.keyFrameDelegate addKeyFrameToParameter:self.parameter withValue:[self currentParameterValue]];
            
            if(newKeyFrame){
                self.selectedKeyframe = newKeyFrame;
            }
        }
    }
    else{
        [self.parameter setValue:[self currentParameterValue] forKeyFrame:self.selectedKeyframe];
    }
    
}

#pragma mark  Storing Parameter Values


/**
 * Stores the current value of the controls representing the paramter as it's value.
 *
 * If the parameter doesn't have any keyFrames yet, the value is stored in the parameter's defaultValue otherwise in a keyFrame.
 */
-(void) storeParameterValue{
    
    id currentValue = [self currentParameterValue];
    
    if(!self.parameter.animation.keyFrames.count){
        if(![self.parameter isKindOfClass:[VSOptionParameter class]]){
            switch (self.parameter.dataType) {
                case VSParameterDataTypeBool:
                    self.parameter.defaultBoolValue= [currentValue boolValue];
                    break;
                case VSParameterDataTypeFloat:
                    self.parameter.defaultFloatValue = [currentValue floatValue];
                    break;
                case VSParameterDataTypeString:
                    self.parameter.defaultStringValue = currentValue;
                    break;
                default:
                    self.parameter.defaultStringValue = currentValue;
                    break;
            }
        }
        else
        {
            self.parameter.defaultValue = currentValue;
        }
        
    }
    
    //If the selectedKeyframe is nil a new KeyFrame is added
    else{
        if(self.selectedKeyframe){
            [self.parameter setValue:currentValue forKeyFrame:self.selectedKeyframe];
        }
        else{
            [self addNewKeyFrame];
        }
    }
}

/**
 * Current Value of the controls representing a parameters value
 *
 * @return Value of the controls according to the parameter's dataType
 */
-(id) currentParameterValue{
    
    id value = nil;
    
    if(![self.parameter isKindOfClass:[VSOptionParameter class]]){
        switch (self.parameter.dataType) {
            case VSParameterDataTypeBool:
                value = [NSNumber numberWithBool:[self boolValueForButtonState:self.checkBox.state]];
                break;
            case VSParameterDataTypeFloat:
                value = [NSNumber numberWithFloat:[self.textField floatValue]];
                break;
            case VSParameterDataTypeString:
                value = [self.textField stringValue];
                break;
            default:
                value = [self.textField stringValue];
                break;
        }
    }
    else{
        value = [((VSOptionParameter*)self.parameter).options objectForKey:[self.comboBox objectValueOfSelectedItem]];
    }
    
    return value;
}

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

#pragma mark Show Parameter

/**
 * Shows the parameter stored in the parameter property according to its VSParameterDataType
 */
-(void) updateParameterValue{
    [self.nameLabel setStringValue: NSLocalizedString(self.parameter.name, @"")];
    
    if([self.parameter isKindOfClass:[VSOptionParameter class]]){
        [self.comboBox selectItemWithObjectValue:((VSOptionParameter*)self.parameter).selectedKey];
    }
    else{
        switch (self.parameter.dataType) {
            case VSParameterDataTypeBool:
                [self.checkBox setState:[self buttonStateOfBooleanValue:self.parameter.currentBoolValue]];
                break;
            case VSParameterDataTypeFloat:
                [self.horizontalSlider setFloatValue:self.parameter.currentFloatValue];
                [self.textField setFloatValue:self.parameter.currentFloatValue];
                break;
            case VSParameterDataTypeString:
                [self.textField setStringValue:self.parameter.currentStringValue];
                break;
            default:
                [self.textField setStringValue:self.parameter.currentStringValue];
                break;
        }
    }
}

/**
 * According to the parameter's dataType different controls are shown
 */
-(void) showParameter{
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
 * Creates an comboBox filled with the options stored in the VSOptionParameter
 */
-(void) showOptionParameter{
    self.comboBox = [[NSComboBox alloc] init];
    [self.comboBox setEditable:NO];
    [self.comboBox setDelegate:self];
    
    [self.parameterHolder addSubview:self.comboBox];
    
    NSSize size = self.comboBox.intrinsicContentSize;
    size.width = 0;
    
    [self.comboBox setFrameSize:size];
    
    //inits the options of the comboBox
    for(id key in ((VSOptionParameter*) self.parameter).options){
        [self.comboBox addItemWithObjectValue:key];
    }
    
    //sets the currently selected item
    [self.comboBox selectItemWithObjectValue:((VSOptionParameter*)self.parameter).selectedKey];
    
    
    //sets the constraints
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.comboBox,@"comboBox", nil];
    NSString *constraintString = [NSString stringWithFormat:@"|-[comboBox]-|"];
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDictionary];
    
    [self.comboBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.parameterHolder addConstraints:constraints];
}

/**
 * Shows paramters of the type VSParameterDataTypeString.
 */
-(void) showStringParameter{
    
    self.textField = [[NSTextField alloc]init];
    [self.parameterHolder addSubview:self.textField];
    
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.textField setFrameSize:self.textField.intrinsicContentSize];
    [self.textField setStringValue:self.parameter.currentStringValue];
    [self.textField setTarget:self];
    [self.textField setAction:@selector(textValueHasChanged:)];
    [self.textField setDelegate:self];
    
    
    // create the constraints
    NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.textField,@"textValueField", nil];
    NSString *constraintString = [NSString stringWithFormat:@"|-[textValueField]-|"];
    
    NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [self.parameterHolder removeConstraints:self.parameterHolder.constraints];
    
    [self.parameterHolder addConstraints:constraints];
}

/**
 * Shows paramters of the type VSParameterDataTypeBool.
 */
-(void) showBoolParameter{
    
    self.checkBox = [[NSButton alloc]init];
    [self.checkBox setTitle:self.parameter.name];
    [self.checkBox setButtonType:NSSwitchButton];
    [self.checkBox setState:[self buttonStateOfBooleanValue:self.parameter.currentBoolValue]];
    
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
    
    [self.textField setFloatValue:self.parameter.currentFloatValue];
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

/**
 * Creates the constraints for parameter of dataType VSParameterDataTypeFloat and with hasRange = YES
 */
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

/**
 * Inits the value slider
 */
-(void) initValueSlider{
    [self.horizontalSlider setMinValue:self.parameter.range.min];
    [self.horizontalSlider setMaxValue:self.parameter.range.max];
    [self.horizontalSlider setFloatValue:self.parameter.currentFloatValue];
    
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

@end
