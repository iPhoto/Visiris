//
//  VSTrackLabelsViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTrackLabel;

/**
 * Subclass of NSViewController and responsible for VSTracksLablView
 */
@interface VSTrackLabelsViewController : NSViewController

/**
 * Initials the view of the VSTrackLabelsViewController with the given frameRect
 * @param frameRect NSRect the VSTrackLabelsViewController's view will be set to
 * @return self
 */
-(id) initWithFrame:(NSRect) frameRect;

/**
 * Adds the given VSTrackLable to the contorllers list of labels and takes care that the newly added label will be display in VSTrackLablesView
 * @param aTrackLabel VSTrackLabel to be added
 */
-(void) addTrackLabel:(VSTrackLabel*) aTrackLabel;

@end
