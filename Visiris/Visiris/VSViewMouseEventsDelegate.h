//
//  VSViewMouseEventsDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSViewMouseEventsDelegate <NSObject>

-(void) mouseMoved:(NSEvent*) theEvent onView:(NSView*) view;

@end
