//
//  VSTimelineObjectPropertiesView.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.08.12.
//
//

#import "VSTimelineObjectPropertiesView.h"

@implementation VSTimelineObjectPropertiesView

-(void) setFrame:(NSRect)frameRect{
    [super setFrame:frameRect];
    if(self.resizingDelegate){
        if([self.resizingDelegate conformsToProtocol:@protocol(VSFrameResizingDelegate) ]){
            if([self.resizingDelegate respondsToSelector:@selector(frameOfView:wasSetTo:)]){
                [self.resizingDelegate frameOfView:self wasSetTo:frameRect];
            }
        }
    }
}

@end
