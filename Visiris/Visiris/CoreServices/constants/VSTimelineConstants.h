//
//  VSViewConstants.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/** Default length of the Timeline in milliseconds */
extern double VSTimelineDefaultDuration;

/** Ratio between the Duration and the Pixel-Length of the timeline */
extern float VSTimelineDefaultPixelRatio;

/** Default duration of an ProjectItem based on an non time-based file like images */
extern double VSDefaultProjectItemDuration;

/** Name of the Measurement-Unit for the NSRulerView in VSTimelineView */
extern NSString *VSTimelineRulerMeasurementUnit;

/** Abbreviation of the Measurement-Unit for the NSRulerView in VSTimelineView */
extern NSString *VSTimelineRulerMeasurementAbreviation;

/** Height of VSTrackView on the VSTimelineView */
extern NSInteger VSTrackViewHeight;

/** Margin between the VSSTrackView on VSTimelineView */
extern NSInteger VSTrackViewMargin;
