//
//  VSDisclosableView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 06.11.12.
//
//

#import "VSDisclosureView.h"

@implementation VSDisclosureView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib{
    [disclosureButton setTarget:self];
    [disclosureButton setAction:@selector(disclosureButtonStateDidChange:)];
}

- (IBAction)disclosureButtonStateDidChange:(NSButton*)sender{
    
    if(sender.state == [contentView isHidden]){
        if(sender.state){
            [contentView setHidden:NO];
        }
        else{
            [contentView setHidden:YES];
        }
    }
    
//    if(sender.state){
//        if(self.view)
//    }
//    
//    if([sender isEqual:self.devicesDisclosureButton]){
//        NSView *viewToHide = [self.devicesDisclosureWrapperView.subviews objectAtIndex:0];
//        if(!sender.state){
//            [viewToHide setHidden:YES];
//            NSPoint newOrigin = self.parametersDisclosureWrapperView.frame.origin;
//            newOrigin.y += viewToHide.frame.size.height;
//            [self.parametersDisclosureWrapperView setFrameOrigin:newOrigin];
//        }
//        else{
//            [viewToHide setHidden:NO];
//            NSPoint newOrigin = self.parametersDisclosureWrapperView.frame.origin;
//            newOrigin.y -= viewToHide.frame.size.height;
//            [self.parametersDisclosureWrapperView setFrameOrigin:newOrigin];
//        }
//    }
//    else if([sender isEqual:self.parametersDisclosureButton]){
//        NSView *viewToHide = [self.parametersDisclosureWrapperView.subviews objectAtIndex:0];
//        if(!sender.state){
//            [viewToHide setHidden:YES];
//        }
//        else{
//            [viewToHide setHidden:NO];
//        }
//    }
}

-(NSView*) contentView{
    return contentView;
}

@end
