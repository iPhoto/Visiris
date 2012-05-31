//
//  VSParameterViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSParameter;

@interface VSParameterViewController : NSViewController
@property (weak) IBOutlet NSTextField *nameLabel;

/** The textField displays the value of parameters of the type VSParameterDataTypeString or VSParameterDataTypeFloat where hasRange is NO. */
@property (weak) IBOutlet NSTextField *textValueField;

/** The checkBox displays the value of parameters of the type VSParameterDataTypeBool. */
@property (weak) IBOutlet NSButton *boolValueField;

/** The textField displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES. */
@property (weak) IBOutlet NSSlider *valueSlider;

/** The slider displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES. Min and Max of slider are set according to the valueRange property of the parameter.*/
@property (weak) IBOutlet NSTextField *valueSliderText;


@property VSParameter *parameter;

/** 
 * Called when the value of the textField has changed.
 * 
 * The textField displays the value of parameters of the type VSParameterDataTypeString or VSParameterDataTypeFloat where hasRange is NO.
 * @param sender Control that called the action.
 */
- (IBAction)textValueHasChanged:(id)sender;

/** 
 * Called when the checkBox state has been changed. 
 * 
 * The textField displays the value of parameters of the type VSParameterDataTypeBool.
 * @param sender Control that called the action.
 */  
- (IBAction)boolValueHasChanged:(NSButton *)sender;

/** 
 * Called when the value of the textField next to slider has been changed. 
 *
 * The textField displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES.
 * @param sender Control that called the action.
 */
- (IBAction)valueSliderTextHasChanged:(NSTextField *)sender;


/** 
 * Called when the value of the slider has been changed. 
 * 
 * The slider displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES. Min and Max of slider are set according to the valueRange property of the parameter.
 * @param sender Control that called the action.
 */
- (IBAction)sliderValueHasChanged:(NSSlider *)sender;



#pragma mark - init

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNib;

#pragma mark - Methods

/**
 * Saves the current values of the parameter and removes the observer on parameter.animation.defaultValue
 */
-(void) saveParameterAndRemoveObserver;

@end
