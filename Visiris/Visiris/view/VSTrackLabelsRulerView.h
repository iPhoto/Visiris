//
//  VSTrackLabelsView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTrackLabel;

/**
 * Subclass of NSRulerView for displaying information of the timelines tracks as vertical ruler view of the timeline's scroll view
 */
@interface VSTrackLabelsRulerView : NSRulerView

/** NSArray of VSTrackLable objects holding the text and the positions of the tracklabels*/
@property (strong) NSMutableArray *trackLabels;

/** Adds a new label to the view 
 * @param aTrackLabel VSTrackLabel storing the informaiton to be displayed in the label
 */
-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel;


@end
