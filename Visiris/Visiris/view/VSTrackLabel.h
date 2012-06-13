//
//  VSTrackLabel.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSTrackLabel : NSObject

#pragma mark - Properties

@property NSString *name; 
@property NSInteger trackID;
@property NSRect frame;

#pragma mark - Init

-(id) initWithName:(NSString*) aName forTrack:(NSInteger) aTrackID forFrame:(NSRect) aFrame;

@end
