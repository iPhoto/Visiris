//
//  VSMainTimelineScrollView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import "VSTimelineScrollView.h"

@class VSTrackLabel;

@interface VSMainTimelineScrollView : VSTimelineScrollView

/**
 * Adds a new TrackLabel to the VSTrackLabelsRulerView used as vertical ruler
 *
 * @param aTrackLabel VSTrackLabel holding the information about the label to add
 */
-(void) addTrackLabel:(VSTrackLabel *)aTrackLabel;

@end
