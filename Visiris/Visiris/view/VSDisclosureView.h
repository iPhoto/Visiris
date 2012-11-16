//
//  VSDisclosableView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.11.12.
//
//

#import <Cocoa/Cocoa.h>
#import "VSDisclosureContentView.h"

@class VSDisclosureView;



@protocol VSDisclosureViewDelegate <NSObject>

-(BOOL) willHideContentOfDisclosureView:(VSDisclosureView*) disclosureView;

-(void) didHideContentOfDisclosureView:(VSDisclosureView*) disclosureView;

-(BOOL) willShowContentOfDisclosureView:(VSDisclosureView*) disclosureView;

-(void) didShowContentOfDisclosureView:(VSDisclosureView*) disclosureView;

-(void) contentSizeDidChangeOfDisclosureView:(VSDisclosureView*) disclosureView;

@end

@interface VSDisclosureView : NSView<VSDisclosureContentViewDelegate>{
    IBOutlet NSButton *disclosureButton;
    IBOutlet VSDisclosureContentView *contentView;
    IBOutlet NSView *viewBelow;
    IBOutlet NSView *nextView;
    IBOutlet id<VSDisclosureViewDelegate> delegate;
    IBOutlet NSView *controlsHolder;
}

@property (readonly) NSView *contentView;

-(float) controlAreaHeight;

@end
