//
//  VSTrackLabel.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Holding information about the text and the position of track label to be displayed in the VSTracksLabelView
 */
@interface VSTrackLabel : NSObject

#pragma mark - Properties

/** Name of the track */
@property NSString *name;

/** id of the track */
@property NSInteger trackID;

/**Position and Dimensions of the label */
@property NSRect frame;

#pragma mark - Init

/**
 * Inits the label and sets the given values 
 * @param aName Name of the track the label will be displayed for
 * @param aTrackID ID of the track the label will be displayed for
 * @param aFrame position and dimensions of the label
 * @return self
 */
-(id) initWithName:(NSString*) aName forTrack:(NSInteger) aTrackID forFrame:(NSRect) aFrame;

@end
