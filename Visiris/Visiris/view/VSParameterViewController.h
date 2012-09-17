//
//  VSParameterViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSViewDelegate.h"

@class VSParameter;
@class VSKeyFrame;

@protocol VSParameterViewKeyFrameDelegate <NSObject>

-(VSKeyFrame*) addKeyFrameToParameter:(VSParameter*) parameter withValue:(id) value;

@end

/**
 * Subclass of NSViewController responsible for displaying a VSParameter.
 *
 * Displays controls to edit the parameter's default value depending on the type of the VSParameter the VSParameterViewController represents. 
 */
@interface VSParameterViewController : NSViewController<VSViewDelegate,NSTextFieldDelegate, NSComboBoxDelegate>

/** Displays the name of paramter the View represents */
@property (weak) IBOutlet NSTextField *nameLabel;


@property (weak) IBOutlet NSView *parameterHolder;


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



/** The textField displays the value of parameters of the type VSParameterDataTypeString or VSParameterDataTypeFloat where hasRange is NO. */
@property (strong) NSTextField *textField;

/** The checkBox displays the value of parameters of the type VSParameterDataTypeBool. */
@property (strong) NSButton *checkBox;

/** The textField displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES. */
@property (strong) NSSlider *horizontalSlider;

@property (strong) NSComboBox * comboBox;

@property id<VSParameterViewKeyFrameDelegate> keyFrameDelegate;

@property VSKeyFrame *selectedKeyframe;

- (IBAction)comboBoxSelectionHasChanged:(NSComboBox *)sender;

- (IBAction)keyFrameButton:(id)sender;

#pragma mark - init

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 */
-(id) initWithDefaultNibAndBackgroundColor:(NSColor*) color;

#pragma mark - Methods

/**
 * Saves the current values of the parameter and removes the observer on parameter.animation.defaultValue
 */
-(void) saveParameterAndRemoveObserver;

-(void) showParameter:(VSParameter*) parameter;

@end
