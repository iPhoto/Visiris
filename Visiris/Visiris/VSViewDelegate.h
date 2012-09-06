//
//  VSViewDelegate.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 13.08.12.
//
//

#import <Foundation/Foundation.h>

@protocol VSViewDelegate <NSObject>

-(NSView*) nextKeyViewOfView:(NSView*) view willBeSet:(NSView*) nextKeyView;

@end
