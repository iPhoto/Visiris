//
//  VSFrameResizingDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 19.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSFrameResizingDelegate <NSObject>

-(void) frameOfView:(NSView*) view wasSetTo:(NSRect) newRect;

@end
