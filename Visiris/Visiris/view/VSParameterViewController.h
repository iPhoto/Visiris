//
//  VSParameterViewController.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSParameter;
@class VSKeyFrame;
@class VSParameterViewController;


/**
 * Defines how VSParameterViewController talks to it's delegate
 */
@protocol VSParameterViewKeyFrameDelegate <NSObject>

/**
 * Called when a new KeyFrame should be added to parameter
 *
 * @param parameter VSParameter a new KeyFrame with the given value should be added
 * @param value Value of the KeyFrame that should be added to the Parameter
 *
 * @return The newly created VSKeyFrame if the creation was successfully, nil otherwise
 */
-(VSKeyFrame*) addKeyFrameToParameter:(VSParameter*) parameter withValue:(id) value;

/**
 * Called when VSParameterViewController wants the playhead of the animation timeline move to the next keyFrame of the parameter.
 *
 * @param parameterViewController VSParameterViewController representing the given parameter
 * @param parameter VSParameter holding the keyFrames
 */
-(void) parameterViewController:(VSParameterViewController*) parameterViewController wantsPlayheadToGoToNextKeyFrameOfParameter:(VSParameter*) parameter;

/**
 * Called when VSParameterViewController wants the playhead of the animation timeline move to the previous keyFrame of the parameter.
 *
 * @param parameterViewController VSParameterViewController representing the given parameter
 * @param parameter VSParameter holding the keyFrames
 */
-(void) parameterViewController:(VSParameterViewController*) parameterViewController wantsPlayheadToGoToPreviousFrameOfParameter:(VSParameter*) parameter;

@end








/**
 * Subclass of NSViewController responsible for displaying a VSParameter.
 *
 * Displays controls to edit the parameter's default value depending on the type of the VSParameter the VSParameterViewController represents. 
 */
@interface VSParameterViewController : NSViewController<NSTextFieldDelegate, NSComboBoxDelegate>


#pragma mark - Properties

/** Displays the name of paramter the View represents */
@property (weak) IBOutlet NSTextField *nameLabel;

/** Wrapper view for the parameter controls */
@property (weak) IBOutlet NSView *parameterHolder;

/** The textField displays the value of parameters of the type VSParameterDataTypeString or VSParameterDataTypeFloat where hasRange is NO. */
@property (strong) NSTextField *textField;

/** The checkBox displays the value of parameters of the type VSParameterDataTypeBool. */
@property (strong) NSButton *checkBox;

/** The textField displays the value of parameters of the type SParameterDataTypeFloat where hasRange is YES. */
@property (strong) NSSlider *horizontalSlider;

/** Displays the options of VSOptionParameters */
@property (strong) NSComboBox * comboBox;

/** Delegate VSParameterViewController calls like definend in VSParameterViewKeyFrameDelegate */
@property id<VSParameterViewKeyFrameDelegate> keyFrameDelegate;

/** Currently selected keyFrame. */
@property VSKeyFrame *selectedKeyframe;

#pragma mark - IBAction

/**
 * Called when the jump to previous KeyFrame button was clicked.
 *
 * Tells the delegate to go to previous KeyFrame of the Parameter
 *
 * @param sender Control that called the action.
 */
- (IBAction)previousKeyFrame:(id)sender;

/**
 * Called when the jump to next KeyFrame button was clicked.
 *
 * Tells the delegate to go to next KeyFrame of the Parameter
 *
 * @param sender Control that called the action.
 */
- (IBAction)nextKeyFrame:(id)sender;

/** 
 * Called when the value of the textField has changed.
 * 
 * The textField displays the value of parameters of the type VSParameterDataTypeString or VSParameterDataTypeFloat where hasRange is NO.
 *
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

/**
 * Adds a new Keyframe at the current position of the playhead in the animation timeline
 *
 * @param sender Control that called the action.
 */
- (IBAction)keyFrameButton:(id)sender;

#pragma mark - init

/**
 * Inits the controller with the .nib-File stored in defaultNib (VSBrowserView)
 *
 * @param color Background-Color of the view
 *
 * @return self
 */
-(id) initWithDefaultNibAndBackgroundColor:(NSColor*) color;

#pragma mark - Methods

/**
 * Saves the current values of the parameter and removes the observer on parameter.animation.defaultValue
 */
-(void) saveParameterAndRemoveObserver;

/**
 * Shows the neccessary controls according to the type of the parameter
 *
 * @param parameter VSParameter to show
 */
-(void) showParameter:(VSParameter*) parameter;

@end
