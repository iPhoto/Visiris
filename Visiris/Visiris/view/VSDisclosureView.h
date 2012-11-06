//
//  VSDisclosableView.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.11.12.
//
//

#import <Cocoa/Cocoa.h>

@interface VSDisclosureView : NSView{
    IBOutlet NSButton *disclosureButton;
    IBOutlet NSView *contentView;
    IBOutlet NSView *viewBelow;
}

@property (readonly) NSView *contentView;


@end
