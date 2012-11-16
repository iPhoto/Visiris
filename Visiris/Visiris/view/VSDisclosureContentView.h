//
//  VSDisclosureContentView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 12.11.12.
//
//

#import <Cocoa/Cocoa.h>

@protocol VSDisclosureContentViewDelegate <NSObject>

-(void) contentDidChange;

@end

@interface VSDisclosureContentView : NSView

@property id<VSDisclosureContentViewDelegate> delegate;

@end
