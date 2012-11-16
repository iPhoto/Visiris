//
//  VSTimelineObjectDevicesViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 07.11.12.
//
//

#import <Cocoa/Cocoa.h>

@class VSTimelineObject;

@interface VSTimelineObjectDevicesViewController : NSViewController

-(id) initWithDefaultNibAndDeviceViewHeight:(float)deviceViewHeight;

-(void) showDevicesOfTimelineObject:(VSTimelineObject*)timelineObject;

-(void) reset;


@end
