//
//  VSTrackLabelsViewController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSTrackLabel;

@interface VSTrackLabelsViewController : NSViewController

-(id) initWithFrame:(NSRect) frameRect;

-(void) addTrackLabel:(VSTrackLabel*) aTrackLabel;

@end
